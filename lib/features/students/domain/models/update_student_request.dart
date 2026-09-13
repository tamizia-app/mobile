class UpdateStudentRequest {
  const UpdateStudentRequest({
    required this.code,
    required this.age,
    required this.gender,
  });

  final String code;
  final int age;
  final String gender;
}
