import 'exercise_integrity.dart';

class MCResponse {
  const MCResponse({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedOptionId,
    this.isCorrect,
    this.exerciseScore,
    this.technicalStatus = TechnicalStatus.valid,
    this.scoreEligible = true,
  });

  final String responseId;
  final String exerciseAttemptId;
  final String selectedOptionId;
  final bool? isCorrect;
  final double? exerciseScore;
  final TechnicalStatus technicalStatus;
  final bool scoreEligible;
}

class OSResponse {
  const OSResponse({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedSyllables,
    this.formedWord,
    this.isCorrect,
    this.exerciseScore,
    this.technicalStatus = TechnicalStatus.valid,
    this.scoreEligible = true,
  });

  final String responseId;
  final String exerciseAttemptId;
  final List<String> selectedSyllables;
  final String? formedWord;
  final bool? isCorrect;
  final double? exerciseScore;
  final TechnicalStatus technicalStatus;
  final bool scoreEligible;
}

class SpeakingResponse {
  const SpeakingResponse({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.audioBlobPath,
    this.originalFilename,
    this.contentType,
    this.durationMs,
    this.recognizedText,
    this.assessmentRecognizedText,
    this.pronunciationScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    this.exerciseScore,
    this.technicalStatus = TechnicalStatus.invalid,
    this.scoreEligible = false,
    this.manualReviewRequired = true,
    this.qualityReasons = const [],
    this.scoringComponents = const ScoringComponents(),
    this.comparison,
    this.review = const ReviewDecision(required: false),
  });

  final String responseId;
  final String exerciseAttemptId;
  final String audioBlobPath;
  final String? originalFilename;
  final String? contentType;
  final int? durationMs;
  final String? recognizedText;
  final String? assessmentRecognizedText;
  final double? pronunciationScore;
  final double? accuracyScore;
  final double? fluencyScore;
  final double? completenessScore;
  final double? prosodyScore;
  final double? exerciseScore;
  final TechnicalStatus technicalStatus;
  final bool scoreEligible;
  final bool manualReviewRequired;
  final List<String> qualityReasons;
  final ScoringComponents scoringComponents;
  final TextComparison? comparison;
  final ReviewDecision review;
}

class WritingResponse {
  const WritingResponse({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.imageBlobPath,
    this.originalFilename,
    this.contentType,
    this.recognizedText,
    this.imageUrl,
    this.strokesJson,
    this.canvasMetadata,
    this.inputMetadata,
    this.frontendMetrics,
    this.metrics,
    this.exerciseScore,
    this.technicalStatus = TechnicalStatus.invalid,
    this.scoreEligible = false,
    this.manualReviewRequired = true,
    this.qualityReasons = const [],
    this.scoringComponents = const ScoringComponents(),
  });

  final String responseId;
  final String exerciseAttemptId;
  final String imageBlobPath;
  final String? originalFilename;
  final String? contentType;
  final String? recognizedText;
  final String? imageUrl;
  final Object? strokesJson;
  final Map<String, dynamic>? canvasMetadata;
  final Map<String, dynamic>? inputMetadata;
  final Map<String, dynamic>? frontendMetrics;
  final WritingMetrics? metrics;
  final double? exerciseScore;
  final TechnicalStatus technicalStatus;
  final bool scoreEligible;
  final bool manualReviewRequired;
  final List<String> qualityReasons;
  final ScoringComponents scoringComponents;
}
