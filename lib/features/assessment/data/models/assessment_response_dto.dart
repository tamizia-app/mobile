import '../../domain/models/assessment_response.dart';

class MCResponseDto {
  const MCResponseDto({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedOptionId,
    this.isCorrect,
  });

  factory MCResponseDto.fromJson(Map<String, dynamic> json) {
    return MCResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      selectedOptionId: _requiredString(json, 'selected_option_id'),
      isCorrect: _optionalBool(json, 'is_correct'),
    );
  }

  final String responseId;
  final String exerciseAttemptId;
  final String selectedOptionId;
  final bool? isCorrect;

  MCResponse toDomain() {
    return MCResponse(
      responseId: responseId,
      exerciseAttemptId: exerciseAttemptId,
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
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
  });

  factory OSResponseDto.fromJson(Map<String, dynamic> json) {
    return OSResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      selectedSyllables: _stringList(json, 'selected_syllables'),
      formedWord: _optionalString(json, 'formed_word'),
      isCorrect: _optionalBool(json, 'is_correct'),
    );
  }

  final String responseId;
  final String exerciseAttemptId;
  final List<String> selectedSyllables;
  final String? formedWord;
  final bool? isCorrect;

  OSResponse toDomain() {
    return OSResponse(
      responseId: responseId,
      exerciseAttemptId: exerciseAttemptId,
      selectedSyllables: selectedSyllables,
      formedWord: formedWord,
      isCorrect: isCorrect,
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
  });

  factory SpeakingResponseDto.fromJson(Map<String, dynamic> json) {
    return SpeakingResponseDto(
      responseId: _requiredString(json, 'response_id'),
      exerciseAttemptId: _requiredString(json, 'exercise_attempt_id'),
      audioBlobPath: _requiredString(json, 'audio_blob_path'),
      originalFilename: _optionalString(json, 'original_filename'),
      contentType: _optionalString(json, 'content_type'),
      durationMs: _optionalInt(json, 'duration_ms'),
      recognizedText:
          _optionalString(json, 'recognized_text') ??
          _optionalString(json, 'free_transcription_text'),
      assessmentRecognizedText: _optionalString(
        json,
        'assessment_recognized_text',
      ),
      pronunciationScore: _optionalDouble(json, 'pronunciation_score'),
      accuracyScore: _optionalDouble(json, 'accuracy_score'),
      fluencyScore: _optionalDouble(json, 'fluency_score'),
      completenessScore: _optionalDouble(json, 'completeness_score'),
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
