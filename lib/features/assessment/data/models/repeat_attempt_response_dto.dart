import '../../domain/models/repeat_attempt_response.dart';

class RepeatAttemptResponseDto {
  const RepeatAttemptResponseDto({
    required this.originalAttemptId,
    required this.newAttemptId,
    required this.assessmentId,
    required this.studentId,
    required this.status,
    this.reason,
    this.exerciseAttempts = const [],
  });

  factory RepeatAttemptResponseDto.fromJson(Map<String, dynamic> json) {
    return RepeatAttemptResponseDto(
      originalAttemptId: _requiredString(json, 'original_attempt_id'),
      newAttemptId: _requiredString(json, 'new_attempt_id'),
      assessmentId: _requiredString(json, 'assessment_id'),
      studentId: _requiredString(json, 'student_id'),
      status: _requiredString(json, 'status'),
      reason: _optionalString(json, 'reason'),
      exerciseAttempts: _readExerciseAttempts(json),
    );
  }

  final String originalAttemptId;
  final String newAttemptId;
  final String assessmentId;
  final String studentId;
  final String status;
  final String? reason;
  final List<Map<String, dynamic>> exerciseAttempts;

  RepeatAttemptResponse toDomain() {
    return RepeatAttemptResponse(
      originalAttemptId: originalAttemptId,
      newAttemptId: newAttemptId,
      assessmentId: assessmentId,
      studentId: studentId,
      status: status,
      reason: reason,
      exerciseAttempts: exerciseAttempts,
    );
  }

  static List<Map<String, dynamic>> _readExerciseAttempts(
    Map<String, dynamic> json,
  ) {
    final value = json['exercise_attempts'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _optionalString(json, key);
  if (value == null || value.isEmpty) {
    throw FormatException('Invalid result field: $key.');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value is num || value is bool ? value.toString() : null;
}

