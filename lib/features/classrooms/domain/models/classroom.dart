class Classroom {
  const Classroom({
    required this.classroomId,
    required this.homeroomTeacherId,
    required this.name,
    required this.gradeLevel,
    required this.section,
    required this.schoolYear,
  });

  final String classroomId;
  final String homeroomTeacherId;
  final String name;
  final String gradeLevel;
  final String section;
  final DateTime schoolYear;

  String get id => classroomId;
}
