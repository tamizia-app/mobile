enum TechnicalStatus {
  valid,
  partial,
  invalid;

  static TechnicalStatus fromApi(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'VALID':
        return TechnicalStatus.valid;
      case 'PARTIAL':
        return TechnicalStatus.partial;
      default:
        return TechnicalStatus.invalid;
    }
  }

  String get apiValue => name.toUpperCase();
}

class ScoringComponents {
  const ScoringComponents({
    this.pronunciationScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    this.lexicalMatch,
    this.confidenceAvg,
    this.cer,
    this.wer,
    this.similarityScore,
    this.isCorrect,
    this.formula,
  });

  final double? pronunciationScore;
  final double? accuracyScore;
  final double? fluencyScore;
  final double? completenessScore;
  final double? prosodyScore;
  final double? lexicalMatch;
  final double? confidenceAvg;
  final double? cer;
  final double? wer;
  final double? similarityScore;
  final bool? isCorrect;
  final String? formula;
}

class TextComparison {
  const TextComparison({
    this.lexicalMatch,
    this.wer,
    this.werPercentage,
    this.matches,
    this.substitutions,
    this.omissions,
    this.insertions,
  });

  final double? lexicalMatch;
  final double? wer;
  final double? werPercentage;
  final int? matches;
  final int? substitutions;
  final int? omissions;
  final int? insertions;
}

class ReviewDecision {
  const ReviewDecision({required this.required, this.reasons = const []});

  final bool required;
  final List<String> reasons;
}

class WritingMetrics {
  const WritingMetrics({
    this.confidenceAvg,
    this.cer,
    this.wer,
    this.similarityScore,
    this.charAccuracy,
    this.wordAccuracy,
    this.durationMs,
    this.strokeCount,
    this.pointCount,
    this.review = const ReviewDecision(required: false),
  });

  final double? confidenceAvg;
  final double? cer;
  final double? wer;
  final double? similarityScore;
  final double? charAccuracy;
  final double? wordAccuracy;
  final int? durationMs;
  final int? strokeCount;
  final int? pointCount;
  final ReviewDecision review;
}
