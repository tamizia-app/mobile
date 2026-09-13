class ResetPasswordRequestDto {
  const ResetPasswordRequestDto({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {'token': token, 'new_password': newPassword};
  }
}
