class CreateClassroomRequest {
  const CreateClassroomRequest({
    required this.name,
    required this.gradeLevel,
    required this.section,
    required this.schoolYear,
  });

  final String name;
  final String gradeLevel;
  final String section;
  final DateTime schoolYear;
}
