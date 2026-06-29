class Student {
  const Student({
    required this.studentId,
    required this.classroomId,
    required this.code,
    required this.age,
    required this.gender,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String studentId;
  final String classroomId;
  final String code;
  final int age;
  final String gender;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get id => studentId;
  String get alias => code;
}
