import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import 'auth_session_storage.dart';

class SecureAuthSessionStorage implements AuthSessionStorage {
  SecureAuthSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'auth_session';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveSession(AuthSession session) async {
    final value = jsonEncode({
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'token_type': session.tokenType,
      'expires_in': session.expiresIn,
      'expires_at': session.expiresAt.toUtc().toIso8601String(),
    });
    try {
      await _storage.write(key: _sessionKey, value: value);
    } catch (_) {
      // The in-memory session remains usable for the current process.
    }
  }

  @override
  Future<AuthSession?> readSession() async {
    try {
      final value = await _storage.read(key: _sessionKey);
      if (value == null || value.isEmpty) {
        return null;
      }
      final json = jsonDecode(value) as Map<String, dynamic>;
      return AuthSession(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        tokenType: json['token_type'] as String,
        expiresIn: json['expires_in'] as int,
        expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
      );
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {
      // A storage failure must not prevent local logout.
    }
  }
}
