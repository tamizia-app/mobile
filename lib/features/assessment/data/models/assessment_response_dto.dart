import '../../domain/models/assessment_response.dart';
import '../../domain/models/exercise_integrity.dart';
import 'exercise_integrity_dto.dart';

class MCResponseDto {
  const MCResponseDto({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedOptionId,
    this.isCorrect,
    this.exerciseScore,
    this.technicalStatus = 'VALID',
    this.scoreEligible = true,
  });

  factory MCResponseDto.fromJson(Map<String, dynamic> json) {
    return MCResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      selectedOptionId: _requiredString(json, 'selected_option_id'),
      isCorrect: _optionalBool(json, 'is_correct'),
      exerciseScore: _optionalDouble(json, 'exercise_score'),
      technicalStatus: _optionalString(json, 'technical_status') ?? 'VALID',
      scoreEligible: _optionalBool(json, 'score_eligible') ?? true,
    );
  }

  final String responseId;
  final String exerciseAttemptId;
  final String selectedOptionId;
  final bool? isCorrect;
  final double? exerciseScore;
  final String technicalStatus;
  final bool scoreEligible;

  MCResponse toDomain() {
    return MCResponse(
      responseId: responseId,
      exerciseAttemptId: exerciseAttemptId,
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
      exerciseScore: exerciseScore,
      technicalStatus: TechnicalStatus.fromApi(technicalStatus),
      scoreEligible: scoreEligible,
    );
  }
}

class OSResponseDto {
  const OSResponseDto({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedSyllables,
    this.formedWord,
    this.isCorrect,
    this.exerciseScore,
    this.technicalStatus = 'VALID',
    this.scoreEligible = true,
  });

  factory OSResponseDto.fromJson(Map<String, dynamic> json) {
    return OSResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      selectedSyllables: _stringList(json, 'selected_syllables'),
      formedWord: _optionalString(json, 'formed_word'),
      isCorrect: _optionalBool(json, 'is_correct'),
      exerciseScore: _optionalDouble(json, 'exercise_score'),
      technicalStatus: _optionalString(json, 'technical_status') ?? 'VALID',
      scoreEligible: _optionalBool(json, 'score_eligible') ?? true,
    );
  }

  final String responseId;
  final String exerciseAttemptId;
  final List<String> selectedSyllables;
  final String? formedWord;
  final bool? isCorrect;
  final double? exerciseScore;
  final String technicalStatus;
  final bool scoreEligible;

  OSResponse toDomain() {
    return OSResponse(
      responseId: responseId,
      exerciseAttemptId: exerciseAttemptId,
      selectedSyllables: selectedSyllables,
      formedWord: formedWord,
      isCorrect: isCorrect,
      exerciseScore: exerciseScore,
      technicalStatus: TechnicalStatus.fromApi(technicalStatus),
      scoreEligible: scoreEligible,
    );
  }
}

class SpeakingResponseDto {
  const SpeakingResponseDto({
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
    this.technicalStatus = 'INVALID',
    this.scoreEligible = false,
    this.manualReviewRequired = true,
    this.qualityReasons = const [],
    this.scoringComponents = const ScoringComponentsDto(),
    this.comparison,
    this.review = const ReviewDecisionDto(required: false),
  });

  factory SpeakingResponseDto.fromJson(Map<String, dynamic> json) {
    return SpeakingResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      audioBlobPath: _requiredString(json, 'audio_blob_path'),
      originalFilename: _optionalString(json, 'original_filename'),
      contentType: _optionalString(json, 'content_type'),
      durationMs: _optionalInt(json, 'duration_ms'),
      recognizedText: _optionalString(json, 'recognized_text'),
      assessmentRecognizedText: _optionalString(
        json,
        'assessment_recognized_text',
      ),
      pronunciationScore: _optionalDouble(json, 'pronunciation_score'),
      accuracyScore: _optionalDouble(json, 'accuracy_score'),
      fluencyScore: _optionalDouble(json, 'fluency_score'),
      completenessScore: _optionalDouble(json, 'completeness_score'),
      prosodyScore: _optionalDouble(json, 'prosody_score'),
      exerciseScore: _optionalDouble(json, 'exercise_score'),
      technicalStatus: _optionalString(json, 'technical_status') ?? 'INVALID',
      scoreEligible: _optionalBool(json, 'score_eligible') ?? false,
      manualReviewRequired:
          _optionalBool(json, 'manual_review_required') ?? true,
      qualityReasons: _stringList(json, 'quality_reasons'),
      scoringComponents: ScoringComponentsDto.fromJson(
        _optionalMap(json, 'scoring_components'),
      ),
      comparison: json['comparison'] is Map<String, dynamic>
          ? TextComparisonDto.fromJson(
              json['comparison'] as Map<String, dynamic>,
            )
          : null,
      review: ReviewDecisionDto.fromJson(_optionalMap(json, 'review')),
    );
  }

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
  final String technicalStatus;
  final bool scoreEligible;
  final bool manualReviewRequired;
  final List<String> qualityReasons;
  final ScoringComponentsDto scoringComponents;
  final TextComparisonDto? comparison;
  final ReviewDecisionDto review;

  SpeakingResponse toDomain() {
    return SpeakingResponse(
      responseId: responseId,
      exerciseAttemptId: exerciseAttemptId,
      audioBlobPath: audioBlobPath,
      originalFilename: originalFilename,
      contentType: contentType,
      durationMs: durationMs,
      recognizedText: recognizedText,
      assessmentRecognizedText: assessmentRecognizedText,
      pronunciationScore: pronunciationScore,
      accuracyScore: accuracyScore,
      fluencyScore: fluencyScore,
      completenessScore: completenessScore,
      prosodyScore: prosodyScore,
      exerciseScore: exerciseScore,
      technicalStatus: TechnicalStatus.fromApi(technicalStatus),
      scoreEligible: scoreEligible,
      manualReviewRequired: manualReviewRequired,
      qualityReasons: qualityReasons,
      scoringComponents: scoringComponents.toDomain(),
      comparison: comparison?.toDomain(),
      review: review.toDomain(),
    );
  }
}

class WritingResponseDto {
  const WritingResponseDto({
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
    this.technicalStatus = 'INVALID',
    this.scoreEligible = false,
    this.manualReviewRequired = true,
    this.qualityReasons = const [],
    this.scoringComponents = const ScoringComponentsDto(),
  });

  factory WritingResponseDto.fromJson(Map<String, dynamic> json) {
    return WritingResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      imageBlobPath: _requiredString(json, 'image_blob_path'),
      originalFilename: _optionalString(json, 'original_filename'),
      contentType: _optionalString(json, 'content_type'),
      recognizedText: _optionalString(json, 'recognized_text'),
      imageUrl: _optionalString(json, 'image_url'),
      strokesJson: json['strokes_json'],
      canvasMetadata: _optionalMap(json, 'canvas_metadata'),
      inputMetadata: _optionalMap(json, 'input_metadata'),
      frontendMetrics: _optionalMap(json, 'frontend_metrics'),
      metrics: json['metrics'] is Map<String, dynamic>
          ? WritingMetricsDto.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      exerciseScore: _optionalDouble(json, 'exercise_score'),
      technicalStatus: _optionalString(json, 'technical_status') ?? 'INVALID',
      scoreEligible: _optionalBool(json, 'score_eligible') ?? false,
      manualReviewRequired:
          _optionalBool(json, 'manual_review_required') ?? true,
      qualityReasons: _stringList(json, 'quality_reasons'),
      scoringComponents: ScoringComponentsDto.fromJson(
        _optionalMap(json, 'scoring_components'),
      ),
    );
  }

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
  final WritingMetricsDto? metrics;
  final double? exerciseScore;
  final String technicalStatus;
  final bool scoreEligible;
  final bool manualReviewRequired;
  final List<String> qualityReasons;
  final ScoringComponentsDto scoringComponents;

  WritingResponse toDomain() {
    return WritingResponse(
      responseId: responseId,
      exerciseAttemptId: exerciseAttemptId,
      imageBlobPath: imageBlobPath,
      originalFilename: originalFilename,
      contentType: contentType,
      recognizedText: recognizedText,
      imageUrl: imageUrl,
      strokesJson: strokesJson,
      canvasMetadata: canvasMetadata,
      inputMetadata: inputMetadata,
      frontendMetrics: frontendMetrics,
      metrics: metrics?.toDomain(),
      exerciseScore: exerciseScore,
      technicalStatus: TechnicalStatus.fromApi(technicalStatus),
      scoreEligible: scoreEligible,
      manualReviewRequired: manualReviewRequired,
      qualityReasons: qualityReasons,
      scoringComponents: scoringComponents.toDomain(),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _optionalString(json, key);
  if (value == null || value.isEmpty) {
    throw FormatException('Invalid response field: $key.');
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
  if (value is num || value is bool) {
    return value.toString();
  }
  return null;
}

bool? _optionalBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is bool ? value : null;
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
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList(growable: false);
}

Map<String, dynamic>? _optionalMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : null;
}
