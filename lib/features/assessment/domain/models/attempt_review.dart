import 'assessment_result.dart';

class AttemptReview {
  const AttemptReview({
    required this.attemptId,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.student,
    this.assessment,
    this.result,
    this.exerciseReviews = const [],
  });

  final String attemptId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final AttemptReviewStudent? student;
  final AttemptReviewAssessment? assessment;
  final AttemptReviewResult? result;
  final List<ExerciseReview> exerciseReviews;
}

class AttemptReviewStudent {
  const AttemptReviewStudent({
    required this.studentId,
    required this.code,
    required this.age,
    required this.gender,
    this.classroom,
  });

  final String studentId;
  final String code;
  final int age;
  final String gender;
  final AttemptReviewClassroom? classroom;
}

class AttemptReviewClassroom {
  const AttemptReviewClassroom({
    required this.classroomId,
    required this.name,
    required this.gradeLevel,
    required this.section,
  });

  final String classroomId;
  final String name;
  final String gradeLevel;
  final String section;
}

class AttemptReviewAssessment {
  const AttemptReviewAssessment({
    required this.assessmentId,
    this.title,
  });

  final String assessmentId;
  final String? title;
}

class AttemptReviewResult {
  const AttemptReviewResult({
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
  });

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
  final List<ExerciseSummary> exerciseSummaries;
}

class ExerciseReview {
  const ExerciseReview({
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
  });

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
}
