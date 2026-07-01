import '../../domain/models/student_attempt_list.dart';

class StudentAttemptListDto {
  const StudentAttemptListDto({
    required this.studentId,
    this.items = const [],
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  factory StudentAttemptListDto.fromJson(Map<String, dynamic> json) {
    return StudentAttemptListDto(
      studentId: _requiredString(json, 'student_id'),
      items: _readItems(json),
      total: _optionalInt(json, 'total') ?? 0,
      limit: _optionalInt(json, 'limit') ?? 20,
      offset: _optionalInt(json, 'offset') ?? 0,
    );
  }

  final String studentId;
  final List<StudentAttemptListItemDto> items;
  final int total;
  final int limit;
  final int offset;

  StudentAttemptList toDomain() {
    return StudentAttemptList(
      studentId: studentId,
      items: items.map((e) => e.toDomain()).toList(growable: false),
      total: total,
      limit: limit,
      offset: offset,
    );
  }

  static List<StudentAttemptListItemDto> _readItems(
    Map<String, dynamic> json,
  ) {
    final value = json['items'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(StudentAttemptListItemDto.fromJson)
        .toList(growable: false);
  }
}

class StudentAttemptListItemDto {
  const StudentAttemptListItemDto({
    required this.attemptId,
    required this.assessmentId,
    this.assessmentName,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.finalScore,
    this.maxScore,
    this.interventionLevel,
    this.totalExercises = 0,
    this.evaluatedExercises = 0,
    this.pendingExercises = 0,
  });

  factory StudentAttemptListItemDto.fromJson(Map<String, dynamic> json) {
    return StudentAttemptListItemDto(
      attemptId: _requiredString(json, 'attempt_id'),
      assessmentId: _requiredString(json, 'assessment_id'),
      assessmentName: _optionalString(json, 'assessment_name'),
      status: _requiredString(json, 'status'),
      startedAt: _optionalDateTime(json, 'started_at'),
      completedAt: _optionalDateTime(json, 'completed_at'),
      finalScore: _optionalDouble(json, 'final_score'),
      maxScore: _optionalDouble(json, 'max_score'),
      interventionLevel: _optionalString(json, 'intervention_level'),
      totalExercises: _optionalInt(json, 'total_exercises') ?? 0,
      evaluatedExercises: _optionalInt(json, 'evaluated_exercises') ?? 0,
      pendingExercises: _optionalInt(json, 'pending_exercises') ?? 0,
    );
  }

  final String attemptId;
  final String assessmentId;
  final String? assessmentName;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? finalScore;
  final double? maxScore;
  final String? interventionLevel;
  final int totalExercises;
  final int evaluatedExercises;
  final int pendingExercises;

  StudentAttemptListItem toDomain() {
    return StudentAttemptListItem(
      attemptId: attemptId,
      assessmentId: assessmentId,
      assessmentName: assessmentName,
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
      finalScore: finalScore,
      maxScore: maxScore,
      interventionLevel: interventionLevel,
      totalExercises: totalExercises,
      evaluatedExercises: evaluatedExercises,
      pendingExercises: pendingExercises,
    );
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

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

double? _optionalDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is num ? value.toDouble() : null;
}
DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
