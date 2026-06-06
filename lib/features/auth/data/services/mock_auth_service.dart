import '../../domain/models/forgot_password_request.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/register_request.dart';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  @override
  Future<bool> login(LoginRequest request) async {
    return request.email.isNotEmpty && request.password.isNotEmpty;
  }

  @override
  Future<bool> register(RegisterRequest request) async {
    return request.email.isNotEmpty && request.password.isNotEmpty;
  }

  @override
  Future<bool> sendPasswordRecovery(ForgotPasswordRequest request) async {
    return request.email.isNotEmpty;
  }
}
