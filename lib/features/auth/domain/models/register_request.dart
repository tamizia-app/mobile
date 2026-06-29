class RegisterRequest {
  const RegisterRequest({
    required this.names,
    required this.lastNames,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.institution,
    required this.phone,
  });

  final String names;
  final String lastNames;
  final String email;
  final String password;
  final String confirmPassword;
  final String institution;
  final String phone;
}
