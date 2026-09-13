import '../../domain/entities/auth_session.dart';

class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'bearer',
      expiresIn: json['expires_in'] as int,
    );
  }

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthSession toDomain() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }
}
