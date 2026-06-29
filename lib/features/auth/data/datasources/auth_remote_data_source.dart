import '../models/auth_response_dto.dart';
import '../models/forgot_password_request_dto.dart';
import '../models/message_response_dto.dart';
import '../models/refresh_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/signin_request_dto.dart';
import '../models/signout_request_dto.dart';
import '../models/signup_request_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseDto> signUp(SignupRequestDto request);

  Future<AuthResponseDto> signIn(SigninRequestDto request);

  Future<AuthResponseDto> refresh(RefreshRequestDto request);

  Future<MessageResponseDto> signOut(SignoutRequestDto request);

  Future<MessageResponseDto> forgotPassword(ForgotPasswordRequestDto request);

  Future<MessageResponseDto> resetPassword(ResetPasswordRequestDto request);
}
