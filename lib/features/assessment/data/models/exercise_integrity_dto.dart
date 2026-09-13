import '../../domain/models/exercise_integrity.dart';

class ScoringComponentsDto {
  const ScoringComponentsDto({
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

  factory ScoringComponentsDto.fromJson(Map<String, dynamic>? json) {
    return ScoringComponentsDto(
      pronunciationScore: _double(json?['pronunciation_score']),
      accuracyScore: _double(json?['accuracy_score']),
      fluencyScore: _double(json?['fluency_score']),
      completenessScore: _double(json?['completeness_score']),
      prosodyScore: _double(json?['prosody_score']),
      lexicalMatch: _double(json?['lexical_match']),
      confidenceAvg: _double(json?['confidence_avg']),
      cer: _double(json?['cer']),
      wer: _double(json?['wer']),
      similarityScore: _double(json?['similarity_score']),
      isCorrect: json?['is_correct'] is bool
          ? json!['is_correct'] as bool
          : null,
      formula: json?['formula'] is String ? json!['formula'] as String : null,
    );
  }

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

  ScoringComponents toDomain() => ScoringComponents(
    pronunciationScore: pronunciationScore,
    accuracyScore: accuracyScore,
    fluencyScore: fluencyScore,
    completenessScore: completenessScore,
    prosodyScore: prosodyScore,
    lexicalMatch: lexicalMatch,
    confidenceAvg: confidenceAvg,
    cer: cer,
    wer: wer,
    similarityScore: similarityScore,
    isCorrect: isCorrect,
    formula: formula,
  );
}

class TextComparisonDto {
  const TextComparisonDto({
    this.lexicalMatch,
    this.wer,
    this.werPercentage,
    this.matches,
    this.substitutions,
    this.omissions,
    this.insertions,
  });

  factory TextComparisonDto.fromJson(Map<String, dynamic>? json) =>
      TextComparisonDto(
        lexicalMatch: _double(json?['lexical_match_percentage']),
        wer: _double(json?['wer']),
        werPercentage: _double(json?['wer_percentage']),
        matches: _int(json?['matches']),
        substitutions: _int(json?['substitutions']),
        omissions: _int(json?['omissions']),
        insertions: _int(json?['insertions']),
      );

  final double? lexicalMatch;
  final double? wer;
  final double? werPercentage;
  final int? matches;
  final int? substitutions;
  final int? omissions;
  final int? insertions;

  TextComparison toDomain() => TextComparison(
    lexicalMatch: lexicalMatch,
    wer: wer,
    werPercentage: werPercentage,
    matches: matches,
    substitutions: substitutions,
    omissions: omissions,
    insertions: insertions,
  );
}

class ReviewDecisionDto {
  const ReviewDecisionDto({required this.required, this.reasons = const []});

  factory ReviewDecisionDto.fromJson(Map<String, dynamic>? json) =>
      ReviewDecisionDto(
        required: json?['required'] is bool ? json!['required'] as bool : false,
        reasons: _strings(json?['reasons']),
      );

  final bool required;
  final List<String> reasons;
  ReviewDecision toDomain() =>
      ReviewDecision(required: required, reasons: reasons);
}

class WritingMetricsDto {
  const WritingMetricsDto({
    this.confidenceAvg,
    this.cer,
    this.wer,
    this.similarityScore,
    this.charAccuracy,
    this.wordAccuracy,
    this.durationMs,
    this.strokeCount,
    this.pointCount,
    required this.review,
  });

  factory WritingMetricsDto.fromJson(Map<String, dynamic>? json) =>
      WritingMetricsDto(
        confidenceAvg: _double(json?['confidence_avg']),
        cer: _double(json?['cer']),
        wer: _double(json?['wer']),
        similarityScore: _double(json?['similarity_score']),
        charAccuracy: _double(json?['char_accuracy']),
        wordAccuracy: _double(json?['word_accuracy']),
        durationMs: _int(json?['duration_ms']),
        strokeCount: _int(json?['stroke_count']),
        pointCount: _int(json?['point_count']),
        review: ReviewDecisionDto(
          required: json?['review_required'] is bool
              ? json!['review_required'] as bool
              : false,
          reasons: _strings(json?['review_reasons']),
        ),
      );

  final double? confidenceAvg;
  final double? cer;
  final double? wer;
  final double? similarityScore;
  final double? charAccuracy;
  final double? wordAccuracy;
  final int? durationMs;
  final int? strokeCount;
  final int? pointCount;
  final ReviewDecisionDto review;

  WritingMetrics toDomain() => WritingMetrics(
    confidenceAvg: confidenceAvg,
    cer: cer,
    wer: wer,
    similarityScore: similarityScore,
    charAccuracy: charAccuracy,
    wordAccuracy: wordAccuracy,
    durationMs: durationMs,
    strokeCount: strokeCount,
    pointCount: pointCount,
    review: review.toDomain(),
  );
}

double? _double(Object? value) => value is num ? value.toDouble() : null;
int? _int(Object? value) => value is num ? value.toInt() : null;
List<String> _strings(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const [];
