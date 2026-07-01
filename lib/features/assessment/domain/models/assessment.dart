class Assessment {
  const Assessment({
    required this.assessmentId,
    required this.classroomId,
    required this.templateId,
    this.status,
    this.title,
    this.homeroomTeacherId,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
  });

  final String assessmentId;
  final String classroomId;
  final String templateId;
  final String? status;
  final String? title;
  final String? homeroomTeacherId;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get id => assessmentId;
}
