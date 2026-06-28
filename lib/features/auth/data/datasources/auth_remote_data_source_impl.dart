import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/auth_response_dto.dart';
import '../models/forgot_password_request_dto.dart';
import '../models/message_response_dto.dart';
import '../models/refresh_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/signin_request_dto.dart';
import '../models/signout_request_dto.dart';
import '../models/signup_request_dto.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AuthResponseDto> signUp(SignupRequestDto request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signup',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AuthResponseDto> signIn(SigninRequestDto request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signin',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AuthResponseDto> refresh(RefreshRequestDto request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<MessageResponseDto> signOut(SignoutRequestDto request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/signout',
        data: request.toJson(),
      );
      return MessageResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<MessageResponseDto> forgotPassword(
    ForgotPasswordRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/forgot-password',
        data: request.toJson(),
      );
      return MessageResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<MessageResponseDto> resetPassword(
    ResetPasswordRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        '/api/v1/auth/reset-password',
        data: request.toJson(),
      );
      return MessageResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
}
