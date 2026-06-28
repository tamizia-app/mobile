class ForgotPasswordRequestDto {
  const ForgotPasswordRequestDto({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}
