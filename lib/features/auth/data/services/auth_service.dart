import '../../domain/models/forgot_password_request.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/register_request.dart';

abstract class AuthService {
  Future<bool> login(LoginRequest request);

  Future<bool> register(RegisterRequest request);

  Future<bool> sendPasswordRecovery(ForgotPasswordRequest request);
}
