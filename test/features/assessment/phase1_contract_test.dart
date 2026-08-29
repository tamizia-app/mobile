import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/features/assessment/data/models/assessment_response_dto.dart';
import 'package:tamizai_app/features/assessment/data/models/assessment_result_dto.dart';
import 'package:tamizai_app/features/assessment/data/models/attempt_review_dto.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_review.dart';
import 'package:tamizai_app/features/assessment/domain/models/exercise_integrity.dart';
import 'package:tamizai_app/features/assessment/domain/repositories/assessment_repository.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_result_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/attempt_review_page.dart';

void main() {
  testWidgets(
    'API result maps through DTO/domain and renders canonical score',
    (tester) async {
      final result = AssessmentResultDto.fromJson({
        'attempt_id': 'attempt-1',
        'final_score': 82.5,
        'max_score': 100.0,
        'intervention_level': 'LOW',
        'score_denominator': 1,
        'scoring_snapshot': [
          {'exercise_attempt_id': 'ea-1', 'included': true, 'score': 82.5},
        ],
        'total_exercises': 1,
        'evaluated_exercises': 1,
        'pending_exercises': 0,
        'exercise_summaries': [
          {
            'exercise_attempt_id': 'ea-1',
            'exercise_id': 'exercise-1',
            'order_index': 1,
            'type': 'READING_SPEAKING',
            'title': 'Lectura oral',
            'status': 'EVALUATED',
            'score': 82.5,
            'technical_status': 'VALID',
            'score_eligible': true,
            'quality_reasons': <String>[],
            'scoring_components': {
              'pronunciation_score': 80,
              'accuracy_score': 81,
              'fluency_score': 88,
              'completeness_score': 79,
              'lexical_match': 90,
            },
          },
        ],
      }).toDomain();

      expect(result.finalScore, 82.5);
      expect(result.interventionLevel, 'LOW');
      expect(result.scoreDenominator, 1);
      expect(result.scoringSnapshot.single['included'], isTrue);
      expect(result.exerciseSummaries.single.score, 82.5);
      expect(
        result.exerciseSummaries.single.technicalStatus,
        TechnicalStatus.valid,
      );
      expect(result.exerciseSummaries.single.scoreEligible, isTrue);
      expect(
        result.exerciseSummaries.single.scoringComponents.lexicalMatch,
        90.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            settings: RouteSettings(arguments: result),
            builder: (_) => const AssessmentResultPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('82.5%'), findsWidgets);
      expect(find.text('Bajo'), findsOneWidget);
      expect(find.text('VALID'), findsOneWidget);
    },
  );

  test(
    'speaking contract preserves scores, comparison, quality and review',
    () {
      final speaking = SpeakingResponseDto.fromJson({
        'response_id': 'response-1',
        'exercise_attempt_id': 'ea-1',
        'audio_blob_path': 'assessment/audio.wav',
        'recognized_text': 'hola mundo',
        'assessment_recognized_text': 'Hola mundo',
        'pronunciation_score': 85,
        'accuracy_score': 80,
        'fluency_score': 90,
        'completeness_score': 95,
        'exercise_score': 90,
        'technical_status': 'PARTIAL',
        'score_eligible': false,
        'manual_review_required': true,
        'quality_reasons': ['PRONUNCIATION_PROVIDER_FAILED'],
        'comparison': {
          'lexical_match_percentage': 100,
          'wer': 0,
          'wer_percentage': 0,
        },
        'review': {
          'required': true,
          'reasons': ['PRONUNCIATION_PROVIDER_FAILED'],
        },
        'scoring_components': {
          'pronunciation_score': 85,
          'accuracy_score': 80,
          'fluency_score': 90,
          'completeness_score': 95,
          'lexical_match': 100,
          'wer': 0,
        },
      }).toDomain();

      expect(speaking.exerciseScore, 90.0);
      expect(speaking.technicalStatus, TechnicalStatus.partial);
      expect(speaking.scoreEligible, isFalse);
      expect(speaking.pronunciationScore, 85.0);
      expect(speaking.accuracyScore, 80.0);
      expect(speaking.fluencyScore, 90.0);
      expect(speaking.completenessScore, 95.0);
      expect(speaking.comparison?.lexicalMatch, 100.0);
      expect(speaking.comparison?.wer, 0.0);
      expect(speaking.review.required, isTrue);
      expect(speaking.scoringComponents.lexicalMatch, 100.0);
    },
  );

  test('writing contract uses the single canonical OCR field names', () {
    final writing = WritingResponseDto.fromJson({
      'response_id': 'response-2',
      'exercise_attempt_id': 'ea-2',
      'image_blob_path': 'assessment/writing.png',
      'recognized_text': 'El gato duerme.',
      'exercise_score': 86.35,
      'technical_status': 'VALID',
      'score_eligible': true,
      'manual_review_required': false,
      'quality_reasons': <String>[],
      'metrics': {
        'confidence_avg': 0.948,
        'cer': 0.071,
        'wer': 0.333,
        'similarity_score': 86.35,
        'char_accuracy': 92.9,
        'word_accuracy': 66.7,
        'review_required': false,
        'review_reasons': <String>[],
      },
      'scoring_components': {
        'confidence_avg': 0.948,
        'cer': 0.071,
        'wer': 0.333,
        'similarity_score': 86.35,
      },
    }).toDomain();

    expect(writing.exerciseScore, 86.35);
    expect(writing.technicalStatus, TechnicalStatus.valid);
    expect(writing.metrics?.confidenceAvg, 0.948);
    expect(writing.metrics?.cer, 0.071);
    expect(writing.metrics?.wer, 0.333);
    expect(writing.metrics?.similarityScore, 86.35);
    expect(writing.metrics?.review.required, isFalse);
    expect(writing.scoringComponents.confidenceAvg, 0.948);
  });

  testWidgets('review DTO renders canonical MC, oral, and OCR fields', (
    tester,
  ) async {
    final review = AttemptReviewDto.fromJson({
      'attempt_id': 'attempt-1',
      'status': 'COMPLETED',
      'started_at': '2026-08-29T10:00:00Z',
      'completed_at': '2026-08-29T10:10:00Z',
      'exercise_reviews': [
        {
          'exercise_attempt_id': 'ea-mc',
          'exercise_id': 'mc',
          'order_index': 1,
          'type': 'MULTIPLE_CHOICE',
          'title': 'Selección',
          'status': 'ANSWERED',
          'score': 100,
          'technical_status': 'VALID',
          'score_eligible': true,
          'question_text': '¿Cuál?',
          'response': {'selected_text': 'Casa', 'is_correct': true},
          'expected': {'correct_text': 'Casa'},
          'scoring_components': {'is_correct': true},
        },
        {
          'exercise_attempt_id': 'ea-speaking',
          'exercise_id': 'speaking',
          'order_index': 2,
          'type': 'READING_SPEAKING',
          'title': 'Oral',
          'status': 'EVALUATED',
          'score': 90,
          'technical_status': 'VALID',
          'score_eligible': true,
          'response': {'recognized_text': 'hola mundo'},
          'scoring_components': {
            'pronunciation_score': 85,
            'accuracy_score': 80,
            'fluency_score': 90,
            'completeness_score': 95,
            'lexical_match': 100,
          },
        },
        {
          'exercise_attempt_id': 'ea-writing',
          'exercise_id': 'writing',
          'order_index': 3,
          'type': 'READING_WRITING',
          'title': 'Escritura',
          'status': 'EVALUATED',
          'score': 86.35,
          'technical_status': 'VALID',
          'score_eligible': true,
          'response': {'recognized_text': 'El gato duerme.'},
          'scoring_components': {
            'confidence_avg': 0.948,
            'cer': 0.071,
            'wer': 0.333,
            'similarity_score': 86.35,
          },
        },
      ],
    }).toDomain();

    await tester.pumpWidget(
      MaterialApp(
        home: AttemptReviewPage(
          assessmentRepository: _ReviewRepository(review),
          attemptId: 'attempt-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Casa'), findsNWidgets(2));
    expect(find.text('Métricas de pronunciación:'), findsOneWidget);
    expect(find.text('Pron: 85%'), findsOneWidget);
    expect(find.text('Prec: 80%'), findsOneWidget);
    expect(find.text('Fluid: 90%'), findsOneWidget);
    expect(find.text('Comp: 95%'), findsOneWidget);
    expect(find.text('Lex: 100%'), findsOneWidget);
    expect(find.text('Métricas de OCR:'), findsOneWidget);
    expect(find.text('Conf: 95%'), findsOneWidget);
    expect(find.text('CER: 7%'), findsOneWidget);
    expect(find.text('WER: 33%'), findsOneWidget);
  });
}

class _ReviewRepository implements AssessmentRepository {
  _ReviewRepository(this.review);

  final AttemptReview review;

  @override
  Future<AttemptReview> getAttemptReview(String attemptId) async => review;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
