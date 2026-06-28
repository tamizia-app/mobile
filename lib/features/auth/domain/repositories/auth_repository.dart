import '../entities/auth_session.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signUp(RegisterRequest request);

  Future<AuthSession> signIn(LoginRequest request);

  Future<AuthSession> refresh(String refreshToken);

  Future<void> signOut(String refreshToken);

  Future<String> forgotPassword(String email);

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  });
}
