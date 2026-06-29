class Assessment {
  const Assessment({
    required this.assessmentId,
    required this.classroomId,
    required this.templateId,
    this.status,
  });

  final String assessmentId;
  final String classroomId;
  final String templateId;
  final String? status;

  String get id => assessmentId;
}
