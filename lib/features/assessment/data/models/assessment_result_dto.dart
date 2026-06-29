import '../../domain/models/assessment_result.dart';

class AssessmentResultDto {
  const AssessmentResultDto({
    required this.attemptId,
    this.finalScore,
    this.maxScore,
    this.mcCorrectCount,
    this.osCorrectCount,
    this.speakingCompletedCount,
    this.writingCompletedCount,
    this.interventionLevel,
    this.generatedAt,
    this.speakingAverageScore,
    this.speakingReviewRequiredCount = 0,
    this.totalExercises = 0,
    this.evaluatedExercises = 0,
    this.pendingExercises = 0,
    this.writingAverageScore,
    this.writingReviewRequiredCount = 0,
  });

  factory AssessmentResultDto.fromJson(Map<String, dynamic> json) {
    return AssessmentResultDto(
      attemptId: _requiredString(json, 'attempt_id'),
      finalScore: _optionalDouble(json, 'final_score'),
      maxScore: _optionalDouble(json, 'max_score'),
      mcCorrectCount: _optionalInt(json, 'mc_correct_count'),
      osCorrectCount: _optionalInt(json, 'os_correct_count'),
      speakingCompletedCount: _optionalInt(json, 'speaking_completed_count'),
      writingCompletedCount: _optionalInt(json, 'writing_completed_count'),
      interventionLevel: _optionalString(json, 'intervention_level'),
      generatedAt: _optionalDateTime(json, 'generated_at'),
      speakingAverageScore: _optionalDouble(json, 'speaking_average_score'),
      speakingReviewRequiredCount:
          _optionalInt(json, 'speaking_review_required_count') ?? 0,
      totalExercises: _optionalInt(json, 'total_exercises') ?? 0,
      evaluatedExercises: _optionalInt(json, 'evaluated_exercises') ?? 0,
      pendingExercises: _optionalInt(json, 'pending_exercises') ?? 0,
      writingAverageScore: _optionalDouble(json, 'writing_average_score'),
      writingReviewRequiredCount:
          _optionalInt(json, 'writing_review_required_count') ?? 0,
    );
  }

  final String attemptId;
  final double? finalScore;
  final double? maxScore;
  final int? mcCorrectCount;
  final int? osCorrectCount;
  final int? speakingCompletedCount;
  final int? writingCompletedCount;
  final String? interventionLevel;
  final DateTime? generatedAt;
  final double? speakingAverageScore;
  final int speakingReviewRequiredCount;
  final int totalExercises;
  final int evaluatedExercises;
  final int pendingExercises;
  final double? writingAverageScore;
  final int writingReviewRequiredCount;

  AssessmentResult toDomain() {
    return AssessmentResult(
      attemptId: attemptId,
      finalScore: finalScore,
      maxScore: maxScore,
      mcCorrectCount: mcCorrectCount,
      osCorrectCount: osCorrectCount,
      speakingCompletedCount: speakingCompletedCount,
      writingCompletedCount: writingCompletedCount,
      interventionLevel: interventionLevel,
      generatedAt: generatedAt,
      speakingAverageScore: speakingAverageScore,
      speakingReviewRequiredCount: speakingReviewRequiredCount,
      totalExercises: totalExercises,
      evaluatedExercises: evaluatedExercises,
      pendingExercises: pendingExercises,
      writingAverageScore: writingAverageScore,
      writingReviewRequiredCount: writingReviewRequiredCount,
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
  if (value == null) {
    return null;
  }
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value is num || value is bool ? value.toString() : null;
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

double? _optionalDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is num ? value.toDouble() : null;
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
