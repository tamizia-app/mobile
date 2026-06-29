import '../../domain/models/assessment.dart';

class AssessmentDto {
  const AssessmentDto({
    required this.assessmentId,
    this.classroomId,
    this.templateId,
    this.status,
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
    );
  }

  final String assessmentId;
  final String? classroomId;
  final String? templateId;
  final String? status;

  Assessment toDomain({
    required String classroomIdFallback,
    required String templateIdFallback,
  }) {
    return Assessment(
      assessmentId: assessmentId,
      classroomId: classroomId ?? classroomIdFallback,
      templateId: templateId ?? templateIdFallback,
      status: status,
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
