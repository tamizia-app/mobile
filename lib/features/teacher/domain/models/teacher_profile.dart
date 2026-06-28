class TeacherProfile {
  const TeacherProfile({
    required this.teacherId,
    required this.name,
    required this.lastname,
    required this.email,
    required this.instituteName,
    required this.phone,
  });

  final String teacherId;
  final String name;
  final String lastname;
  final String email;
  final String? instituteName;
  final String? phone;

  String get fullName => '$name $lastname'.trim();
}
