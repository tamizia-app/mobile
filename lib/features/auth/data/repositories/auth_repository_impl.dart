import '../../domain/entities/auth_session.dart';
import '../../domain/models/login_request.dart';
import '../../domain/models/register_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/forgot_password_request_dto.dart';
import '../models/refresh_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/signin_request_dto.dart';
import '../models/signout_request_dto.dart';
import '../models/signup_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> signUp(RegisterRequest request) async {
    final response = await _remoteDataSource.signUp(
      SignupRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }

  @override
  Future<AuthSession> signIn(LoginRequest request) async {
    final response = await _remoteDataSource.signIn(
      SigninRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _remoteDataSource.refresh(
      RefreshRequestDto(refreshToken: refreshToken),
    );
    return response.toDomain();
  }

  @override
  Future<void> signOut(String refreshToken) async {
    await _remoteDataSource.signOut(
      SignoutRequestDto(refreshToken: refreshToken),
    );
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await _remoteDataSource.forgotPassword(
      ForgotPasswordRequestDto(email: email),
    );
    return response.message;
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _remoteDataSource.resetPassword(
      ResetPasswordRequestDto(token: token, newPassword: newPassword),
    );
    return response.message;
  }
}
