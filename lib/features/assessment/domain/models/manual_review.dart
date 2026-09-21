enum ManualReviewAction {
  confirm('confirm'),
  overrideMetrics('override_metrics'),
  correctEvidence('correct_evidence'),
  revert('revert');

  const ManualReviewAction(this.apiValue);
  final String apiValue;
}

enum ManualReviewStatus {
  notRequired('not_required'),
  pending('pending'),
  confirmed('confirmed'),
  overridden('overridden'),
  reverted('reverted'),
  unknown('unknown');

  const ManualReviewStatus(this.apiValue);
  final String apiValue;

  static ManualReviewStatus fromApi(String? value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => unknown,
  );
}

enum MetricSource {
  automatic('automatic'),
  reviewedEvidence('recalculated_from_reviewed_evidence'),
  teacherOverride('teacher_override'),
  unknown('unknown');

  const MetricSource(this.apiValue);
  final String apiValue;

  static MetricSource fromApi(String? value) => values.firstWhere(
    (source) => source.apiValue == value,
    orElse: () => unknown,
  );
}

/// Read-only interpretation of the analysis returned by GET review.
/// No text alignment or score is computed in the client.
class ReviewAnalysis {
  const ReviewAnalysis({
    this.recognizedText,
    this.expectedText,
    this.cer,
    this.wer,
    this.werPercentage,
    this.lexicalMatch,
    this.alignment = const [],
  });

  final String? recognizedText;
  final String? expectedText;
  final double? cer;
  final double? wer;
  final double? werPercentage;
  final double? lexicalMatch;
  final List<ReviewAlignmentItem> alignment;
}

class ReviewAlignmentItem {
  const ReviewAlignmentItem({
    required this.operation,
    this.expected,
    this.recognized,
  });
  final String operation;
  final String? expected;
  final String? recognized;
}

class ReviewEvidence {
  const ReviewEvidence({
    this.imageUrl,
    this.audioUrl,
    this.recognizedText,
    this.freeTranscriptionText,
    this.assessmentRecognizedText,
    this.reviewedRecognizedText,
    this.reviewedFreeTranscriptionText,
  });

  final String? imageUrl;
  final String? audioUrl;
  final String? recognizedText;
  final String? freeTranscriptionText;
  final String? assessmentRecognizedText;
  final String? reviewedRecognizedText;
  final String? reviewedFreeTranscriptionText;
}

class ReviewHistoryEvent {
  const ReviewHistoryEvent({
    required this.action,
    this.reviewVersion,
    this.teacherId,
    this.observation,
    this.createdAt,
    this.correctedText,
    this.manualMetrics = const {},
    this.metricSources = const {},
  });

  final String action;
  final int? reviewVersion;
  final String? teacherId;
  final String? observation;
  final DateTime? createdAt;
  final String? correctedText;
  final Map<String, double?> manualMetrics;
  final Map<String, MetricSource> metricSources;
}

class ManualReviewDetails {
  const ManualReviewDetails({
    this.originalScore,
    this.currentScore,
    this.reviewVersion,
    this.status = ManualReviewStatus.unknown,
    this.manualAdjustmentApplied = false,
    this.originalMetrics = const {},
    this.currentMetrics = const {},
    this.metricSources = const {},
    this.evidence = const ReviewEvidence(),
    this.automaticAnalysis,
    this.reviewedAnalysis,
    this.history = const [],
    this.observation,
    this.adjustedByTeacherId,
    this.adjustedAt,
  });

  final double? originalScore;
  final double? currentScore;
  // A missing version is not silently treated as version zero.
  final int? reviewVersion;
  final ManualReviewStatus status;
  final bool manualAdjustmentApplied;
  final Map<String, double?> originalMetrics;
  final Map<String, double?> currentMetrics;
  final Map<String, MetricSource> metricSources;
  final ReviewEvidence evidence;
  final ReviewAnalysis? automaticAnalysis;
  final ReviewAnalysis? reviewedAnalysis;
  final List<ReviewHistoryEvent> history;
  final String? observation;
  final String? adjustedByTeacherId;
  final DateTime? adjustedAt;

  bool get hasReview => (reviewVersion ?? 0) > 0;
}

class ManualReviewRequest {
  const ManualReviewRequest({
    required this.action,
    required this.observation,
    required this.baseReviewVersion,
    this.recognizedText,
    this.freeTranscriptionText,
    this.metrics = const {},
  });

  final ManualReviewAction action;
  final String observation;
  final int baseReviewVersion;
  final String? recognizedText;
  final String? freeTranscriptionText;
  final Map<String, double> metrics;
}

class ManualReviewResponse {
  const ManualReviewResponse({
    required this.exerciseAttemptId,
    required this.exerciseType,
    required this.reviewVersion,
    required this.status,
    required this.scoreEligible,
    required this.manualReviewRequired,
    required this.manualAdjustmentApplied,
    this.originalScore,
    this.currentScore,
    this.originalMetrics = const {},
    this.currentMetrics = const {},
    this.metricSources = const {},
    this.event,
    this.observation,
    this.adjustedByTeacherId,
    this.adjustedAt,
    this.assessmentResult,
  });

  final String exerciseAttemptId;
  final String exerciseType;
  final int reviewVersion;
  final ManualReviewStatus status;
  final bool scoreEligible;
  final bool manualReviewRequired;
  final bool manualAdjustmentApplied;
  final double? originalScore;
  final double? currentScore;
  final Map<String, double?> originalMetrics;
  final Map<String, double?> currentMetrics;
  final Map<String, MetricSource> metricSources;
  final ReviewHistoryEvent? event;
  final String? observation;
  final String? adjustedByTeacherId;
  final DateTime? adjustedAt;
  final ManualReviewAssessmentResult? assessmentResult;
}

class ManualReviewAssessmentResult {
  const ManualReviewAssessmentResult({
    this.originalFinalScore,
    this.currentFinalScore,
  });
  final double? originalFinalScore;
  final double? currentFinalScore;
}

class ManualReviewArgs {
  const ManualReviewArgs({
    required this.attemptId,
    required this.exerciseAttemptId,
  });
  final String attemptId;
  final String exerciseAttemptId;
}
