class MCResponse {
  const MCResponse({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedOptionId,
    this.isCorrect,
  });

  final String responseId;
  final String exerciseAttemptId;
  final String selectedOptionId;
  final bool? isCorrect;
}

class OSResponse {
  const OSResponse({
    required this.responseId,
    required this.exerciseAttemptId,
    required this.selectedSyllables,
    this.formedWord,
    this.isCorrect,
  });

  final String responseId;
  final String exerciseAttemptId;
  final List<String> selectedSyllables;
  final String? formedWord;
  final bool? isCorrect;
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
}
