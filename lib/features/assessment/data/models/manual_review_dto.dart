import '../../domain/models/manual_review.dart';

class ManualReviewRequestDto {
  const ManualReviewRequestDto(this.request);
  final ManualReviewRequest request;

  Map<String, dynamic> toJson() => {
    'action': request.action.apiValue,
    'teacher_observation': request.observation.trim(),
    'base_review_version': request.baseReviewVersion,
    if (request.action == ManualReviewAction.overrideMetrics)
      'metrics': request.metrics,
    if (request.action == ManualReviewAction.correctEvidence)
      'corrections': {
        if (request.recognizedText != null)
          'recognized_text': request.recognizedText!.trim(),
        if (request.freeTranscriptionText != null)
          'free_transcription_text': request.freeTranscriptionText!.trim(),
      },
  };
}

class ManualReviewDetailsDto {
  const ManualReviewDetailsDto(this.json);
  final Map<String, dynamic> json;

  ManualReviewDetails toDomain() {
    final metrics = _map(json['metrics']);
    final evidence = _map(json['response']);
    return ManualReviewDetails(
      originalScore: _number(json['original_score']),
      currentScore: _number(json['current_score']),
      reviewVersion: _version(json['review_version']),
      status: ManualReviewStatus.fromApi(_text(json['review_status'])),
      manualAdjustmentApplied: json['manual_adjustment_applied'] == true,
      originalMetrics: _numbers(metrics['original_metrics']),
      currentMetrics: _numbers(metrics['current_metrics']),
      metricSources: _sources(json['metric_sources']),
      evidence: ReviewEvidence(
        imageUrl: _text(evidence['image_url']),
        audioUrl: _text(evidence['audio_url']),
        recognizedText: _text(evidence['recognized_text']),
        freeTranscriptionText: _text(evidence['free_transcription_text']),
        assessmentRecognizedText: _text(evidence['assessment_recognized_text']),
        reviewedRecognizedText: _text(evidence['reviewed_recognized_text']),
        reviewedFreeTranscriptionText: _text(
          evidence['reviewed_free_transcription_text'],
        ),
      ),
      automaticAnalysis: _analysis(json['automatic_analysis']),
      reviewedAnalysis: _analysis(json['reviewed_analysis']),
      history: json['manual_review_history'] is List
          ? (json['manual_review_history'] as List)
                .whereType<Map<String, dynamic>>()
                .map(_history)
                .toList(growable: false)
          : const [],
      observation: _text(json['teacher_observation']),
      adjustedByTeacherId: _text(json['adjusted_by_teacher_id']),
      adjustedAt: _date(json['adjusted_at']),
    );
  }
}

class ManualReviewResponseDto {
  const ManualReviewResponseDto(this.json);
  factory ManualReviewResponseDto.fromJson(Map<String, dynamic> json) {
    if (_version(json['review_version']) == null ||
        _text(json['exercise_attempt_id']) == null ||
        _text(json['exercise_type']) == null) {
      throw const FormatException('Invalid manual review response.');
    }
    return ManualReviewResponseDto(json);
  }
  final Map<String, dynamic> json;

  ManualReviewResponse toDomain() {
    final result = _map(json['assessment_result']);
    return ManualReviewResponse(
      exerciseAttemptId: _text(json['exercise_attempt_id'])!,
      exerciseType: _text(json['exercise_type'])!,
      reviewVersion: _version(json['review_version'])!,
      status: ManualReviewStatus.fromApi(_text(json['review_status'])),
      scoreEligible: json['score_eligible'] == true,
      manualReviewRequired: json['manual_review_required'] == true,
      manualAdjustmentApplied: json['manual_adjustment_applied'] == true,
      originalScore: _number(json['original_score']),
      currentScore: _number(json['current_score']),
      originalMetrics: _numbers(json['original_metrics']),
      currentMetrics: _numbers(json['current_metrics']),
      metricSources: _sources(json['metric_sources']),
      event: json['review_event_summary'] is Map<String, dynamic>
          ? _history(_map(json['review_event_summary']))
          : null,
      observation: _text(json['teacher_observation']),
      adjustedByTeacherId: _text(json['adjusted_by_teacher_id']),
      adjustedAt: _date(json['adjusted_at']),
      assessmentResult: json['assessment_result'] == null
          ? null
          : ManualReviewAssessmentResult(
              originalFinalScore: _number(result['original_final_score']),
              currentFinalScore: _number(result['current_final_score']),
            ),
    );
  }
}

ReviewAnalysis? _analysis(Object? value) {
  if (value is! Map<String, dynamic>) return null;
  return ReviewAnalysis(
    recognizedText: _text(value['recognized_text']),
    expectedText: _text(value['expected_text']),
    cer: _number(value['cer']),
    wer: _number(value['wer']),
    werPercentage: _number(value['wer_percentage']),
    lexicalMatch: _number(value['lexical_match_percentage']),
    alignment: value['alignment'] is List
        ? (value['alignment'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => ReviewAlignmentItem(
                  operation: _text(item['operation']) ?? 'unknown',
                  expected: _text(item['expected']),
                  recognized: _text(item['recognized']),
                ),
              )
              .toList(growable: false)
        : const [],
  );
}

ReviewHistoryEvent _history(Map<String, dynamic> json) {
  final corrections = _map(json['corrections']);
  return ReviewHistoryEvent(
    action: _text(json['action']) ?? 'unknown',
    reviewVersion: _version(json['review_version']),
    teacherId: _text(json['teacher_id']),
    observation: _text(json['teacher_observation']),
    createdAt: _date(json['created_at']),
    correctedText:
        _text(corrections['recognized_text']) ??
        _text(corrections['free_transcription_text']),
    manualMetrics: _numbers(json['manual_metrics']),
    metricSources: _sources(json['metric_sources']),
  );
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const {};

Map<String, double?> _numbers(Object? value) => Map.unmodifiable(
  _map(value).map((key, item) => MapEntry(key, _number(item))),
);

Map<String, MetricSource> _sources(Object? value) => Map.unmodifiable(
  _map(
    value,
  ).map((key, item) => MapEntry(key, MetricSource.fromApi(_text(item)))),
);

double? _number(Object? value) =>
    value is num && value.isFinite ? value.toDouble() : null;
String? _text(Object? value) => value is String ? value : null;
int? _version(Object? value) => value is int && value >= 0 ? value : null;
DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
