import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thrown for any non-2xx API response. [statusCode] lets callers branch on
/// 401/403/404/409/422 etc. without parsing the message string.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Centralized HTTP client: every screen/service goes through here so the
/// API base URL and ID-token attachment live in exactly one place (per the
/// project's API-first architecture requirement -- no component talks to
/// the backend directly with a raw http.get/post call of its own).
///
/// Override the base URL per environment with:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.23:5000/api/v1
/// The default (10.0.2.2) is the special alias the Android emulator uses to
/// reach the host machine's localhost. iOS simulator can use localhost
/// directly; a physical device needs your machine's LAN IP.
class ApiClient {
  static const String _defaultBaseUrl = 'http://10.0.2.2:5000/api/v1';
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// The signed-in user's Firebase ID token. Firebase caches it and silently
  /// refreshes it shortly before it expires (they last an hour), so there is
  /// no token to store or renew by hand. Null when nobody is signed in.
  /// Throws a network ApiException if a needed refresh could not reach
  /// Firebase: that is "offline", not "logged out", and callers must be able
  /// to tell the difference.
  static Future<String?> getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw ApiException(0, 'Could not reach the server. Check your connection.');
      }
      return null; // e.g. account disabled or deleted: treated as signed out
    }
  }

  /// A real reachability check, not just "does the device have a network
  /// interface up" -- a phone can be on Wi-Fi with no route to this
  /// specific backend (captive portal, VPN, server down, wrong LAN). Short
  /// timeout so a dead server doesn't hang whatever's waiting on this.
  static Future<bool> pingBackend() async {
    try {
      final healthUrl = Uri.parse(baseUrl).replace(path: '/api/health');
      final response = await http.get(healthUrl).timeout(const Duration(seconds: 4));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = query == null
        ? null
        : {
            for (final entry in query.entries)
              if (entry.value != null && entry.value.toString().isNotEmpty) entry.key: entry.value.toString(),
          };
    return Uri.parse('$baseUrl$path').replace(queryParameters: cleanQuery?.isEmpty == true ? null : cleanQuery);
  }

  static dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  static dynamic _handle(http.Response response) {
    final body = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = (body is Map && body['message'] is String)
        ? body['message'] as String
        : 'Request failed (${response.statusCode})';
    throw ApiException(response.statusCode, message);
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    try {
      final response = await http.get(_uri(path, query), headers: await _headers(withAuth: auth));
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('GET $path failed: $e');
      throw ApiException(0, 'Could not reach the server. Check your connection.');
    }
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http.post(_uri(path), headers: await _headers(withAuth: auth), body: jsonEncode(body ?? {}));
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('POST $path failed: $e');
      throw ApiException(0, 'Could not reach the server. Check your connection.');
    }
  }

  static Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(_uri(path), headers: await _headers(), body: jsonEncode(body ?? {}));
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('PUT $path failed: $e');
      throw ApiException(0, 'Could not reach the server. Check your connection.');
    }
  }

  static Future<dynamic> delete(String path) async {
    try {
      final response = await http.delete(_uri(path), headers: await _headers());
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('DELETE $path failed: $e');
      throw ApiException(0, 'Could not reach the server. Check your connection.');
    }
  }

  /// Multipart upload -- JSON-only get/post/put/delete above can't carry a
  /// file, so this is the one place a request is built differently. Still
  /// goes through the same base URL, auth header, and error handling as
  /// everything else.
  static Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    String? contentType,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      final token = await getToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (fields != null) request.fields.addAll(fields);
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          filePath,
          // Without this, MultipartFile.fromPath defaults to
          // application/octet-stream, which the backend's upload
          // validation always rejects -- every document upload failed
          // with 400 until this was threaded through from the caller.
          contentType: contentType == null ? null : MediaType.parse(contentType),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('UPLOAD $path failed: $e');
      throw ApiException(0, 'Could not reach the server. Check your connection.');
    }
  }

  /// Raw bytes for downloading a stored document (auth-protected, so this
  /// can't just be a plain network image/file URL).
  static Future<Uint8List> getBytes(String path) async {
    try {
      final response = await http.get(_uri(path), headers: await _headers());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      final body = _decode(response);
      final message = (body is Map && body['message'] is String) ? body['message'] as String : 'Request failed (${response.statusCode})';
      throw ApiException(response.statusCode, message);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print('GET (bytes) $path failed: $e');
      throw ApiException(0, 'Could not reach the server. Check your connection.');
    }
  }
}
