import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_user.dart';
import 'api_client.dart';
import 'hive_service.dart';

/// Everything auth-related: register, login, session persistence, logout.
/// The JWT and last-known user are cached in secure storage so the app can
/// restore a session on cold start without another login.
class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'auth_user';

  static AppUser? _cachedUser;
  static AppUser? get cachedUser => _cachedUser;

  static Future<AppUser> register({required String name, required String email, required String password}) async {
    final data = await ApiClient.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
      auth: false,
    );
    return _persistSession(data);
  }

  static Future<AppUser> login({required String email, required String password}) async {
    final data = await ApiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );
    return _persistSession(data);
  }

  static Future<AppUser> _persistSession(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await ApiClient.saveToken(token);
    await _storage.write(key: _userKey, value: jsonEncode(data['user']));
    _cachedUser = user;
    return user;
  }

  /// Validates the stored token against the backend (so an expired/invalid
  /// token doesn't silently let a stale session through) and refreshes the
  /// cached user. Returns null if there is no valid session.
  static Future<AppUser?> restoreSession() async {
    final token = await ApiClient.getToken();
    if (token == null) return null;

    try {
      final data = await ApiClient.get('/auth/me');
      final user = AppUser.fromJson(data as Map<String, dynamic>);
      _cachedUser = user;
      await _storage.write(key: _userKey, value: jsonEncode(data));
      return user;
    } on ApiException {
      await logout();
      return null;
    }
  }

  static Future<void> logout() async {
    await ApiClient.clearToken();
    await _storage.delete(key: _userKey);
    _cachedUser = null;
    await HiveService.clearAssetCache();
  }
}
