class AssessmentResult {
  const AssessmentResult({
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
}
