class SignoutRequestDto {
  const SignoutRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}
