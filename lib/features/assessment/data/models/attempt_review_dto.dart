import '../../domain/models/attempt_review.dart';
import 'assessment_result_dto.dart';
import '../../domain/models/exercise_integrity.dart';
import 'exercise_integrity_dto.dart';

class AttemptReviewDto {
  const AttemptReviewDto({
    required this.attemptId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.student,
    this.assessment,
    this.result,
    this.exerciseReviews = const [],
  });

  factory AttemptReviewDto.fromJson(Map<String, dynamic> json) {
    return AttemptReviewDto(
      attemptId: _requiredString(json, 'attempt_id'),
      status: _requiredString(json, 'status'),
      startedAt: _optionalDateTime(json, 'started_at'),
      completedAt: _optionalDateTime(json, 'completed_at'),
      student: json['student'] != null
          ? AttemptReviewStudentDto.fromJson(
              json['student'] as Map<String, dynamic>,
            )
          : null,
      assessment: json['assessment'] != null
          ? AttemptReviewAssessmentDto.fromJson(
              json['assessment'] as Map<String, dynamic>,
            )
          : null,
      result: json['result'] != null
          ? AttemptReviewResultDto.fromJson(
              json['result'] as Map<String, dynamic>,
            )
          : null,
      exerciseReviews: _readExerciseReviews(json),
    );
  }

  final String attemptId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final AttemptReviewStudentDto? student;
  final AttemptReviewAssessmentDto? assessment;
  final AttemptReviewResultDto? result;
  final List<ExerciseReviewDto> exerciseReviews;

  AttemptReview toDomain() {
    return AttemptReview(
      attemptId: attemptId,
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
      student: student?.toDomain(),
      assessment: assessment?.toDomain(),
      result: result?.toDomain(),
      exerciseReviews: exerciseReviews
          .map((e) => e.toDomain())
          .toList(growable: false),
    );
  }

  static List<ExerciseReviewDto> _readExerciseReviews(
    Map<String, dynamic> json,
  ) {
    final value = json['exercise_reviews'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ExerciseReviewDto.fromJson)
        .toList(growable: false);
  }
}

class AttemptReviewStudentDto {
  const AttemptReviewStudentDto({
    required this.studentId,
    required this.code,
    required this.age,
    required this.gender,
    this.classroom,
  });

  factory AttemptReviewStudentDto.fromJson(Map<String, dynamic> json) {
    return AttemptReviewStudentDto(
      studentId: _requiredString(json, 'student_id'),
      code: _requiredString(json, 'code'),
      age: _optionalInt(json, 'age') ?? 0,
      gender: _requiredString(json, 'gender'),
      classroom: json['classroom'] != null
          ? AttemptReviewClassroomDto.fromJson(
              json['classroom'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String studentId;
  final String code;
  final int age;
  final String gender;
  final AttemptReviewClassroomDto? classroom;

  AttemptReviewStudent toDomain() {
    return AttemptReviewStudent(
      studentId: studentId,
      code: code,
      age: age,
      gender: gender,
      classroom: classroom?.toDomain(),
    );
  }
}

class AttemptReviewClassroomDto {
  const AttemptReviewClassroomDto({
    required this.classroomId,
    required this.name,
    required this.gradeLevel,
    required this.section,
  });

  factory AttemptReviewClassroomDto.fromJson(Map<String, dynamic> json) {
    return AttemptReviewClassroomDto(
      classroomId: _requiredString(json, 'classroom_id'),
      name: _requiredString(json, 'name'),
      gradeLevel: _requiredString(json, 'grade_level'),
      section: _requiredString(json, 'section'),
    );
  }

  final String classroomId;
  final String name;
  final String gradeLevel;
  final String section;

  AttemptReviewClassroom toDomain() {
    return AttemptReviewClassroom(
      classroomId: classroomId,
      name: name,
      gradeLevel: gradeLevel,
      section: section,
    );
  }
}

class AttemptReviewAssessmentDto {
  const AttemptReviewAssessmentDto({required this.assessmentId, this.title});

  factory AttemptReviewAssessmentDto.fromJson(Map<String, dynamic> json) {
    return AttemptReviewAssessmentDto(
      assessmentId: _requiredString(json, 'assessment_id'),
      title: _optionalString(json, 'title'),
    );
  }

  final String assessmentId;
  final String? title;

  AttemptReviewAssessment toDomain() {
    return AttemptReviewAssessment(assessmentId: assessmentId, title: title);
  }
}

class AttemptReviewResultDto {
  const AttemptReviewResultDto({
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
    this.exerciseSummaries = const [],
    this.scoreDenominator = 0,
    this.scoringSnapshot = const [],
  });

  factory AttemptReviewResultDto.fromJson(Map<String, dynamic> json) {
    return AttemptReviewResultDto(
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
      exerciseSummaries: _readExerciseSummaries(json),
      scoreDenominator: _optionalInt(json, 'score_denominator') ?? 0,
      scoringSnapshot: _readScoringSnapshot(json),
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
  final List<ExerciseSummaryDto> exerciseSummaries;
  final int scoreDenominator;
  final List<Map<String, dynamic>> scoringSnapshot;

  AttemptReviewResult toDomain() {
    return AttemptReviewResult(
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
      exerciseSummaries: exerciseSummaries
          .map((e) => e.toDomain())
          .toList(growable: false),
      scoreDenominator: scoreDenominator,
      scoringSnapshot: scoringSnapshot,
    );
  }

  static List<ExerciseSummaryDto> _readExerciseSummaries(
    Map<String, dynamic> json,
  ) {
    final value = json['exercise_summaries'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ExerciseSummaryDto.fromJson)
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> _readScoringSnapshot(
    Map<String, dynamic> json,
  ) {
    final value = json['scoring_snapshot'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.unmodifiable(item))
        .toList(growable: false);
  }
}

class ExerciseReviewDto {
  const ExerciseReviewDto({
    required this.exerciseAttemptId,
    required this.exerciseId,
    required this.orderIndex,
    required this.type,
    required this.title,
    this.instructions,
    required this.status,
    this.score,
    this.questionText,
    this.promptText,
    this.referenceText,
    this.response,
    this.expected,
    this.metrics,
    this.reviewRequired = false,
    this.reviewReasons = const [],
    this.technicalStatus = 'INVALID',
    this.scoreEligible = false,
    this.qualityReasons = const [],
    this.scoringComponents = const ScoringComponentsDto(),
  });

  factory ExerciseReviewDto.fromJson(Map<String, dynamic> json) {
    return ExerciseReviewDto(
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      exerciseId: _requiredString(json, 'exercise_id'),
      orderIndex: _optionalInt(json, 'order_index') ?? 0,
      type: _requiredString(json, 'type'),
      title: _requiredString(json, 'title'),
      instructions: _optionalString(json, 'instructions'),
      status: _requiredString(json, 'status'),
      score: _optionalDouble(json, 'score'),
      questionText: _optionalString(json, 'question_text'),
      promptText: _optionalString(json, 'prompt_text'),
      referenceText: _optionalString(json, 'reference_text'),
      response: _optionalMap(json, 'response'),
      expected: _optionalMap(json, 'expected'),
      metrics: _optionalMap(json, 'metrics'),
      reviewRequired: _optionalBool(json, 'review_required') ?? false,
      reviewReasons: _readStringList(json, 'review_reasons'),
      technicalStatus: _optionalString(json, 'technical_status') ?? 'INVALID',
      scoreEligible: _optionalBool(json, 'score_eligible') ?? false,
      qualityReasons: _readStringList(json, 'quality_reasons'),
      scoringComponents: ScoringComponentsDto.fromJson(
        _optionalMap(json, 'scoring_components'),
      ),
    );
  }

  final String exerciseAttemptId;
  final String exerciseId;
  final int orderIndex;
  final String type;
  final String title;
  final String? instructions;
  final String status;
  final double? score;
  final String? questionText;
  final String? promptText;
  final String? referenceText;
  final Map<String, dynamic>? response;
  final Map<String, dynamic>? expected;
  final Map<String, dynamic>? metrics;
  final bool reviewRequired;
  final List<String> reviewReasons;
  final String technicalStatus;
  final bool scoreEligible;
  final List<String> qualityReasons;
  final ScoringComponentsDto scoringComponents;

  ExerciseReview toDomain() {
    return ExerciseReview(
      exerciseAttemptId: exerciseAttemptId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      type: type,
      title: title,
      instructions: instructions,
      status: status,
      score: score,
      questionText: questionText,
      promptText: promptText,
      referenceText: referenceText,
      response: response,
      expected: expected,
      metrics: metrics,
      reviewRequired: reviewRequired,
      reviewReasons: reviewReasons,
      technicalStatus: TechnicalStatus.fromApi(technicalStatus),
      scoreEligible: scoreEligible,
      qualityReasons: qualityReasons,
      scoringComponents: scoringComponents.toDomain(),
    );
  }
}

Map<String, dynamic>? _optionalMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  return null;
}

List<String> _readStringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
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

bool? _optionalBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is bool ? value : null;
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
