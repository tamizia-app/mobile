import '../../features/auth/domain/entities/auth_session.dart';

abstract interface class AuthSessionStorage {
  Future<void> saveSession(AuthSession session);

  Future<AuthSession?> readSession();

  Future<void> clearSession();
}
