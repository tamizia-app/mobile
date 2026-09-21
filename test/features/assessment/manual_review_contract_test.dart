import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/network/api_client.dart';
import 'package:tamizai_app/core/network/api_error_mapper.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/features/assessment/data/datasources/assessment_remote_data_source_impl.dart';
import 'package:tamizai_app/features/assessment/data/models/manual_review_dto.dart';
import 'package:tamizai_app/features/assessment/data/repositories/assessment_repository_impl.dart';
import 'package:tamizai_app/features/assessment/domain/models/manual_review.dart';
import 'manual_review_fixtures.dart';

void main() {
  test(
    'GET preserves null, zero, unknown/missing metadata and maps evidence',
    () {
      final details = reviewFrom(
        exerciseJson(),
      ).exerciseReviews.single.manualReview;
      expect(details.originalScore, isNull);
      expect(details.currentScore, 63.5);
      expect(details.currentMetrics['char_accuracy'], 0);
      expect(details.currentMetrics['fluency_score'], isNull);
      expect(details.reviewVersion, 0);
      expect(details.evidence.recognizedText, 'Mi casa azul.');
      final missing = ManualReviewDetailsDto({
        'review_status': 'future_status',
      }).toDomain();
      expect(missing.reviewVersion, isNull);
      expect(missing.status, ManualReviewStatus.unknown);
      expect(missing.automaticAnalysis, isNull);
      expect(missing.currentScore, isNull);
    },
  );

  test(
    'GET maps reviewed text, analyses, sources and history without losing automatic',
    () {
      final json = exerciseJson(type: 'READING_SPEAKING', version: 4);
      (json['response'] as Map)['reviewed_free_transcription_text'] =
          'Mi casa es azul.';
      json['review_status'] = 'overridden';
      json['metric_sources'] = {
        'accuracy_score': 'teacher_override',
        'lexical_match': 'recalculated_from_reviewed_evidence',
        'fluency_score': 'automatic',
      };
      json['automatic_analysis'] = {
        'wer': 0.25,
        'alignment': [
          {'operation': 'omission', 'expected': 'es', 'recognized': null},
        ],
      };
      json['reviewed_analysis'] = {
        'wer': 0,
        'recognized_text': 'Mi casa es azul.',
      };
      json['manual_review_history'] = [
        {
          'action': 'correct_evidence',
          'review_version': 4,
          'teacher_id': 'teacher-1',
          'teacher_observation': 'Contrastado con audio',
          'created_at': '2026-09-20T12:00:00Z',
          'corrections': {'free_transcription_text': 'Mi casa es azul.'},
          'manual_metrics': null,
        },
      ];
      final details = reviewFrom(json).exerciseReviews.single.manualReview;
      expect(details.evidence.freeTranscriptionText, 'Mi casa azul.');
      expect(
        details.evidence.reviewedFreeTranscriptionText,
        'Mi casa es azul.',
      );
      expect(details.automaticAnalysis!.alignment.single.operation, 'omission');
      expect(details.reviewedAnalysis!.wer, 0);
      expect(
        details.metricSources['lexical_match'],
        MetricSource.reviewedEvidence,
      );
      expect(
        details.metricSources['accuracy_score'],
        MetricSource.teacherOverride,
      );
      expect(details.history.single.correctedText, 'Mi casa es azul.');
      expect(details.history.single.createdAt!.isUtc, isTrue);
    },
  );

  test(
    'PATCH response uses its own shape and never supplies a fabricated level',
    () {
      final response = ManualReviewResponseDto.fromJson(
        responseJson(9),
      ).toDomain();
      expect(response.reviewVersion, 9);
      expect(response.originalScore, isNull);
      expect(response.currentMetrics['fluency_score'], 0);
      expect(response.assessmentResult!.currentFinalScore, 76.75);
      expect(response.assessmentResult!.originalFinalScore, isNull);
      expect(
        () => ManualReviewResponseDto.fromJson({'exercise_attempt_id': 'ea-1'}),
        throwsFormatException,
      );
    },
  );

  for (final action in [
    ManualReviewAction.confirm,
    ManualReviewAction.revert,
  ]) {
    test('${action.apiValue} sends only action, observation and version', () {
      final body = ManualReviewRequestDto(
        ManualReviewRequest(
          action: action,
          observation: '  Revisado por docente  ',
          baseReviewVersion: 3,
        ),
      ).toJson();
      expect(body, {
        'action': action.apiValue,
        'teacher_observation': 'Revisado por docente',
        'base_review_version': 3,
      });
    });
  }

  test('corrections use the distinct Writing and Speaking backend keys', () {
    final writing = ManualReviewRequestDto(
      const ManualReviewRequest(
        action: ManualReviewAction.correctEvidence,
        observation: 'OCR contrastado',
        baseReviewVersion: 0,
        recognizedText: ' Mi casa ',
      ),
    ).toJson();
    final speaking = ManualReviewRequestDto(
      const ManualReviewRequest(
        action: ManualReviewAction.correctEvidence,
        observation: 'Audio contrastado',
        baseReviewVersion: 2,
        freeTranscriptionText: ' Mi casa ',
      ),
    ).toJson();
    expect(writing['corrections'], {'recognized_text': 'Mi casa'});
    expect(speaking['corrections'], {'free_transcription_text': 'Mi casa'});
    expect(writing.containsKey('metrics'), isFalse);
    expect(speaking.containsKey('teacher_id'), isFalse);
  });

  test(
    'repository sends authenticated PATCH at real path with only changed metrics',
    () async {
      final client = ApiClient();
      addTearDown(() => client.dio.close(force: true));
      client.configureAuthentication(
        accessTokenProvider: () async => 'test-token',
        refreshSession: () async => false,
      );
      RequestOptions? captured;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: responseJson(8),
              ),
            );
          },
        ),
      );
      final repo = AssessmentRepositoryImpl(
        remoteDataSource: AssessmentRemoteDataSourceImpl(apiClient: client),
      );
      final response = await repo.manualReviewExercise(
        'ea-1',
        const ManualReviewRequest(
          action: ManualReviewAction.overrideMetrics,
          observation: 'Revisé el audio',
          baseReviewVersion: 6,
          metrics: {'accuracy_score': 0, 'fluency_score': 100},
        ),
      );
      expect(captured!.method, 'PATCH');
      expect(
        captured!.path,
        '/api/v1/assessments/exercise-attempts/ea-1/manual-review',
      );
      expect(captured!.headers['Authorization'], 'Bearer test-token');
      expect(captured!.data, {
        'action': 'override_metrics',
        'teacher_observation': 'Revisé el audio',
        'base_review_version': 6,
        'metrics': {'accuracy_score': 0, 'fluency_score': 100},
      });
      expect(response.reviewVersion, 8);
    },
  );

  for (final code in [
    'MANUAL_REVIEW_VERSION_CONFLICT',
    'ASSESSMENT_EVIDENCE_LOCKED',
  ]) {
    test('409 retains $code and a friendly message', () {
      final error = mapHttp(409, {
        'detail': {'code': code, 'current_review_version': 9},
      });
      expect(error, isA<ConflictException>());
      expect((error as ConflictException).code, code);
      expect(error.message, isNot(contains('correo')));
    });
  }
  for (final status in [400, 401, 403, 404, 422, 500]) {
    test('manual review HTTP $status maps to actionable Spanish error', () {
      final error = mapHttp(status, {'detail': 'Internal English detail'});
      expect(error.message, isNot(contains('Internal English')));
      expect(error.message, isNotEmpty);
      if (status == 403) expect(error, isA<ForbiddenException>());
      if (status == 404) expect(error, isA<NotFoundException>());
    });
  }
}

ApiException mapHttp(int status, Object data) {
  final request = RequestOptions(
    path: '/api/v1/assessments/exercise-attempts/ea-1/manual-review',
  );
  return ApiErrorMapper.map(
    DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: request,
        statusCode: status,
        data: data,
      ),
    ),
  );
}
