import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_user.dart';
import 'api_client.dart';
import 'hive_service.dart';

/// Everything auth-related. Sign-up, sign-in and password handling are done
/// by Firebase Authentication; this app never sees or stores a password
/// hash. After signing in we ask our own backend GET /auth/me, which verifies
/// the Firebase ID token and returns (creating on first use) the user's
/// record in MongoDB -- that record's id is what owns every product and
/// document. The last-known record is cached in secure storage so a cold
/// start with no network still opens the app.
class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'auth_user';

  static AppUser? _cachedUser;
  static AppUser? get cachedUser => _cachedUser;

  static Future<AppUser> register({required String name, required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(name);
      // Force a fresh token so it carries the display name; the backend uses
      // that claim to name the new MongoDB record.
      await credential.user!.getIdToken(true);
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
    try {
      return await _loadProfile();
    } on ApiException catch (e) {
      // The Firebase account exists but our server could not be reached.
      // Sign out so the person lands back on a clean login screen instead of
      // a half-finished state; signing in later completes setup.
      await FirebaseAuth.instance.signOut();
      throw ApiException(e.statusCode, 'Account created, but the server could not be reached. Sign in to continue.');
    }
  }

  static Future<AppUser> login({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
    try {
      return await _loadProfile();
    } on ApiException {
      // Signed in with Firebase but the backend call failed: don't leave a
      // Firebase session behind that the login screen does not know about.
      await FirebaseAuth.instance.signOut();
      rethrow;
    }
  }

  static Future<AppUser> _loadProfile() async {
    final data = await ApiClient.get('/auth/me');
    return _persist(data as Map<String, dynamic>);
  }

  static Future<AppUser> _persist(Map<String, dynamic> data) async {
    final user = AppUser.fromJson(data);
    _cachedUser = user;
    await _storage.write(key: _userKey, value: jsonEncode(data));
    return user;
  }

  /// Firebase keeps the user signed in across app restarts on its own. This
  /// confirms that against our backend and refreshes the cached record. If
  /// the device is offline it falls back to the last-known record, so the
  /// offline-first app still opens with the user's saved products; it only
  /// signs out when the server actually rejects the token.
  static Future<AppUser?> restoreSession() async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      await _clearLocal();
      return null;
    }

    try {
      return await _loadProfile();
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await logout();
        return null;
      }
      return _loadCached(fbUser.email);
    }
  }

  static Future<AppUser?> _loadCached(String? email) async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      final user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // Guard against a stale cache from a different account.
      if (email != null && user.email.toLowerCase() != email.toLowerCase()) return null;
      _cachedUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Updates the signed-in user's name on the backend, then refreshes both
  /// the in-memory cache and secure storage so Home/Profile reflect it
  /// immediately without the user having to log out and back in.
  static Future<AppUser> updateProfile({required String name}) async {
    final data = await ApiClient.put('/auth/me', body: {'name': name});
    return _persist(data as Map<String, dynamic>);
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _clearLocal();
  }

  static Future<void> _clearLocal() async {
    await _storage.delete(key: _userKey);
    _cachedUser = null;
    await HiveService.clearAssetCache();
  }

  /// Firebase error codes -> the plain messages the screens already show via
  /// ApiException.
  static ApiException _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return ApiException(401, 'Invalid email or password');
      case 'email-already-in-use':
        return ApiException(409, 'A user with that email already exists');
      case 'weak-password':
        return ApiException(400, 'Password must be at least 6 characters');
      case 'invalid-email':
        return ApiException(400, 'Enter a valid email address');
      case 'user-disabled':
        return ApiException(403, 'This account has been disabled');
      case 'too-many-requests':
        return ApiException(429, 'Too many attempts. Wait a few minutes and try again.');
      case 'network-request-failed':
        return ApiException(0, 'Could not reach the server. Check your connection.');
      default:
        return ApiException(400, e.message ?? 'Authentication failed');
    }
  }
}
