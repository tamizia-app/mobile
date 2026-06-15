class TeacherProfile {
  const TeacherProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.institution,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String institution;

  String get fullName => '$firstName $lastName';

  TeacherProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? institution,
  }) {
    return TeacherProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      institution: institution ?? this.institution,
    );
  }
}
