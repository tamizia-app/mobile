class UpdateTeacherProfileRequest {
  const UpdateTeacherProfileRequest({
    required this.name,
    required this.lastname,
    required this.email,
    required this.instituteName,
    required this.phone,
  });

  final String name;
  final String lastname;
  final String email;
  final String? instituteName;
  final String? phone;
}
