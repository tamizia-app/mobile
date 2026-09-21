import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/features/assessment/data/models/manual_review_dto.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_review.dart';
import 'package:tamizai_app/features/assessment/domain/models/manual_review.dart';
import 'package:tamizai_app/features/assessment/presentation/viewmodels/manual_review_viewmodel.dart';
import 'manual_review_fixtures.dart';

void main() {
  late ReviewRepositoryFake repo;
  late ManualReviewViewModel model;
  setUp(() {
    repo = ReviewRepositoryFake(
      reviewFrom(exerciseJson(type: 'READING_SPEAKING')),
    );
    model = ManualReviewViewModel(
      assessmentRepository: repo,
      attemptId: 'attempt-1',
      exerciseAttemptId: 'ea-1',
    );
  });
  tearDown(() => model.dispose());

  test(
    'load initializes server version; real changes and observation gate saving',
    () async {
      await model.load();
      expect(model.canSave, isFalse);
      model.setMetric('accuracy_score', '70');
      expect(model.hasChanges, isFalse);
      model.setObservation('  ');
      model.setText('Texto corregido');
      expect(model.canSave, isFalse);
      model.setObservation('Contrasté el audio');
      expect(model.canSave, isTrue);
      model.setText('  ');
      expect(model.canSave, isFalse);
      model.setText('Mi casa azul.');
      expect(model.canConfirm, isTrue);
      expect(model.canSave, isFalse);
    },
  );

  test(
    'only four Azure metrics are editable, null stays empty, validation 0–100',
    () async {
      await model.load();
      model.setObservation('Revisé el audio');
      expect(model.metricDrafts['fluency_score'], '');
      model.setMetric('lexical_match', '100');
      expect(model.hasMetricOverrides, isFalse);
      for (final invalid in ['-1', '100.01', 'NaN', 'Infinity', 'abc', '']) {
        model.setMetric('accuracy_score', invalid);
        expect(model.metricError('accuracy_score'), isNotNull, reason: invalid);
        expect(model.canSave, isFalse);
      }
      for (final valid in ['0', '100', '72,5']) {
        model.setMetric('accuracy_score', valid);
        expect(model.canSave, isTrue, reason: valid);
      }
    },
  );

  test(
    'Writing correction sends recognized_text and refreshes server scores',
    () async {
      repo.current = reviewFrom(exerciseJson());
      await model.load();
      model.setText('Mi casa es azul.');
      model.setObservation('La imagen contiene la palabra es');
      repo.onPatch = (request) async {
        final updated = exerciseJson(version: 7)..['current_score'] = 94.75;
        (updated['response'] as Map)['reviewed_recognized_text'] =
            'Mi casa es azul.';
        repo.current = reviewFrom(updated, score: 88.25);
        return ManualReviewResponseDto.fromJson(responseJson(7)).toDomain();
      };
      await model.saveEdits();
      final request = repo.requests.single;
      expect(request.action, ManualReviewAction.correctEvidence);
      expect(request.recognizedText, 'Mi casa es azul.');
      expect(request.freeTranscriptionText, isNull);
      expect(request.baseReviewVersion, 0);
      expect(model.exercise!.manualReview.currentScore, 94.75);
      expect(model.review!.result!.finalScore, 88.25);
      expect(model.isDirty, isFalse);
      expect(repo.reads, 2);
    },
  );

  test(
    'combined edits run sequentially using the returned version, not base + 1',
    () async {
      await model.load();
      model.setText('Mi casa es azul.');
      model.setMetric('accuracy_score', '92');
      model.setObservation('Contrasté texto y pronunciación');
      final first = Completer<ManualReviewResponse>();
      repo.onPatch = (request) async {
        if (request.action == ManualReviewAction.correctEvidence) {
          return first.future;
        }
        return ManualReviewResponseDto.fromJson(responseJson(12)).toDomain();
      };
      final saving = model.saveEdits();
      await Future<void>.delayed(Duration.zero);
      expect(model.isSaving, isTrue);
      expect(model.canSave, isFalse);
      expect(repo.requests.length, 1);
      await model.saveEdits();
      expect(repo.requests.length, 1);
      first.complete(
        ManualReviewResponseDto.fromJson(responseJson(11)).toDomain(),
      );
      await saving;
      expect(repo.requests.map((e) => e.action), [
        ManualReviewAction.correctEvidence,
        ManualReviewAction.overrideMetrics,
      ]);
      expect(repo.requests.first.freeTranscriptionText, 'Mi casa es azul.');
      expect(repo.requests.last.baseReviewVersion, 11);
      expect(repo.requests.last.metrics, {'accuracy_score': 92});
      expect(repo.reads, 2);
    },
  );

  test(
    'partial failure keeps only unsaved metrics for explicit retry',
    () async {
      await model.load();
      model.setText('Mi casa es azul.');
      model.setMetric('accuracy_score', '92');
      model.setObservation('Revisado con audio');
      repo.onPatch = (request) async {
        if (request.action == ManualReviewAction.correctEvidence) {
          final json = exerciseJson(type: 'READING_SPEAKING', version: 7);
          (json['response'] as Map)['reviewed_free_transcription_text'] =
              request.freeTranscriptionText;
          repo.current = reviewFrom(json);
          return ManualReviewResponseDto.fromJson(responseJson(7)).toDomain();
        }
        throw const ValidationException('Métrica no aceptada.');
      };
      await model.saveEdits();
      expect(model.errorMessage, contains('texto ya se guardó'));
      expect(model.hasTextCorrection, isFalse);
      expect(model.hasMetricOverrides, isTrue);
      expect(model.canSave, isTrue);
      repo.onPatch = (_) async =>
          ManualReviewResponseDto.fromJson(responseJson(8)).toDomain();
      await model.saveEdits();
      expect(repo.requests.length, 3);
      expect(repo.requests.last.action, ManualReviewAction.overrideMetrics);
      expect(repo.requests.last.baseReviewVersion, 7);
    },
  );

  test(
    'version conflict refreshes and discards stale text, metrics and observation',
    () async {
      await model.load();
      model.setText('Borrador obsoleto');
      model.setMetric('accuracy_score', '92');
      model.setObservation('Revisado');
      repo.onPatch = (_) async {
        final json = exerciseJson(type: 'READING_SPEAKING', version: 8);
        (json['response'] as Map)['reviewed_free_transcription_text'] =
            'Otro docente corrigió';
        repo.current = reviewFrom(json);
        throw const ConflictException(
          'Actualizada',
          code: 'MANUAL_REVIEW_VERSION_CONFLICT',
        );
      };
      await model.saveEdits();
      expect(repo.requests.length, 1);
      expect(model.editedText, 'Otro docente corrigió');
      expect(model.exercise!.manualReview.reviewVersion, 8);
      expect(model.isDirty, isFalse);
      expect(model.notice, contains('recargados'));
    },
  );

  test(
    'PATCH success followed by GET failure cannot resubmit stale mutation',
    () async {
      await model.load();
      model.setText('Texto corregido');
      model.setObservation('Revisado');
      repo.onRead = () async => throw const NetworkException('Sin conexión');
      await model.saveEdits();
      expect(model.hasMutated, isTrue);
      expect(model.requiresReload, isTrue);
      expect(model.canSave, isFalse);
      expect(model.errorMessage, contains('se guardó'));
      await model.saveEdits();
      expect(repo.requests.length, 1);
    },
  );

  test(
    'uncertain network write reconciles before allowing a new decision',
    () async {
      await model.load();
      model.setObservation('Revisado');
      repo.onPatch = (_) async =>
          throw const ApiTimeoutException('Tiempo agotado');
      await model.confirm();
      expect(repo.reads, 2);
      expect(model.isDirty, isFalse);
      expect(repo.requests.length, 1);
      expect(model.notice, contains('historial'));
    },
  );

  test(
    'confirm and revert require reason and use the current version',
    () async {
      await model.load();
      await model.confirm();
      expect(repo.requests, isEmpty);
      model.setObservation('Automático verificado');
      await model.confirm();
      expect(repo.requests.single.action, ManualReviewAction.confirm);
      expect(repo.requests.single.metrics, isEmpty);
      repo.current = reviewFrom(exerciseJson(version: 9));
      await model.load();
      await model.revert();
      expect(repo.requests.length, 1);
      model.setObservation('Restaurar la evidencia original');
      await model.revert();
      expect(repo.requests.last.action, ManualReviewAction.revert);
      expect(repo.requests.last.baseReviewVersion, 9);
    },
  );

  for (final scenario in [
    'unsupported',
    'unfinished',
    'invalid',
    'missing_version',
  ]) {
    test('$scenario remains read-only without PATCH', () async {
      final json = exerciseJson(
        type: scenario == 'unsupported' ? 'MULTIPLE_CHOICE' : 'READING_WRITING',
        version: scenario == 'missing_version' ? null : 0,
      );
      if (scenario == 'invalid') json['technical_status'] = 'INVALID';
      repo.current = reviewFrom(
        json,
        status: scenario == 'unfinished' ? 'IN_PROGRESS' : 'COMPLETED',
      );
      await model.load();
      model.setText('Texto');
      model.setObservation('Revisado');
      await model.saveEdits();
      expect(model.canEdit, isFalse);
      expect(model.readOnlyReason, isNotNull);
      expect(repo.requests, isEmpty);
    });
  }

  test(
    'finishing an in-flight read after disposal does not notify disposed listeners',
    () async {
      final completer = Completer<AttemptReview>();
      repo.onRead = () => completer.future;
      final separate = ManualReviewViewModel(
        assessmentRepository: repo,
        attemptId: 'attempt-1',
        exerciseAttemptId: 'ea-1',
      );
      final load = separate.load();
      separate.dispose();
      completer.complete(repo.current);
      await load;
    },
  );
}
