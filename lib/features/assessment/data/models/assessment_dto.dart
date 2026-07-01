import '../../domain/models/assessment.dart';

class AssessmentDto {
  const AssessmentDto({
    required this.assessmentId,
    this.classroomId,
    this.templateId,
    this.status,
    this.title,
    this.homeroomTeacherId,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AssessmentDto.fromJson(Map<String, dynamic> json) {
    final assessmentId =
        _optionalString(json, 'assessment_id') ?? _optionalString(json, 'id');
    if (assessmentId == null || assessmentId.isEmpty) {
      throw const FormatException('Invalid assessment response.');
    }
    return AssessmentDto(
      assessmentId: assessmentId,
      classroomId: _optionalString(json, 'classroom_id'),
      templateId: _optionalString(json, 'template_id'),
      status: _optionalString(json, 'status'),
      title: _optionalString(json, 'title'),
      homeroomTeacherId: _optionalString(json, 'homeroom_teacher_id'),
      scheduledAt: _optionalDateTime(json, 'scheduled_at'),
      createdAt: _optionalDateTime(json, 'created_at'),
      updatedAt: _optionalDateTime(json, 'updated_at'),
    );
  }

  final String assessmentId;
  final String? classroomId;
  final String? templateId;
  final String? status;
  final String? title;
  final String? homeroomTeacherId;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Assessment toDomain({
    required String classroomIdFallback,
    required String templateIdFallback,
  }) {
    return Assessment(
      assessmentId: assessmentId,
      classroomId: classroomId ?? classroomIdFallback,
      templateId: templateId ?? templateIdFallback,
      status: status,
      title: title,
      homeroomTeacherId: homeroomTeacherId,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  return null;
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
