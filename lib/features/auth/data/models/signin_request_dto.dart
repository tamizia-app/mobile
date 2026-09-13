import '../../domain/models/login_request.dart';

class SigninRequestDto {
  const SigninRequestDto({required this.email, required this.password});

  factory SigninRequestDto.fromDomain(LoginRequest request) {
    return SigninRequestDto(email: request.email, password: request.password);
  }

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
