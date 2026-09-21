import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/constants/app_routes.dart';
import 'package:tamizai_app/core/widgets/primary_button.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_review.dart';
import 'package:tamizai_app/features/assessment/domain/models/manual_review.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/attempt_review_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/manual_review_page.dart';
import 'package:tamizai_app/features/assessment/presentation/widgets/review_evidence_media.dart';
import 'manual_review_fixtures.dart';

Widget reviewApp(ReviewRepositoryFake repo, {double textScale = 1}) =>
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      initialRoute: '/review',
      routes: {
        '/': (_) => const Scaffold(body: Text('Pantalla anterior')),
        '/review': (_) => ManualReviewPage(
          assessmentRepository: repo,
          args: const ManualReviewArgs(
            attemptId: 'attempt-1',
            exerciseAttemptId: 'ea-1',
          ),
        ),
      },
    );

void main() {
  testWidgets(
    'successful save returns to detail with feedback and no empty reason error',
    (tester) async {
      final repo = ReviewRepositoryFake(reviewFrom(exerciseJson()));
      await tester.pumpWidget(reviewApp(repo));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('reviewed-text')),
        'Texto corregido',
      );
      await tester.enterText(
        find.byKey(const Key('review-observation')),
        'Contrastado con imagen',
      );
      await tester.ensureVisible(find.byKey(const Key('save-review')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-review')));
      await tester.pumpAndSettle();
      expect(find.byType(ManualReviewPage), findsNothing);
      expect(find.text('Pantalla anterior'), findsOneWidget);
      expect(
        find.text('Revisión guardada. Los resultados están actualizados.'),
        findsOneWidget,
      );
      expect(find.text('Escribe el motivo de la revisión.'), findsNothing);
      expect(repo.requests.length, 1);
    },
  );

  testWidgets('failed save stays in the review so the teacher can recover', (
    tester,
  ) async {
    final repo = ReviewRepositoryFake(reviewFrom(exerciseJson()));
    repo.onPatch = (_) async =>
        throw const ValidationException('Revisa la corrección.');
    await tester.pumpWidget(reviewApp(repo));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reviewed-text')),
      'Texto corregido',
    );
    await tester.enterText(
      find.byKey(const Key('review-observation')),
      'Contrastado con imagen',
    );
    await tester.ensureVisible(find.byKey(const Key('save-review')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-review')));
    await tester.pumpAndSettle();
    expect(find.byType(ManualReviewPage), findsOneWidget);
    expect(find.text('Revisa la corrección.'), findsWidgets);
  });
  testWidgets('initial loading, friendly load error and explicit retry', (
    tester,
  ) async {
    final repo = ReviewRepositoryFake(reviewFrom(exerciseJson()));
    final pending = Completer<AttemptReview>();
    repo.onRead = () => pending.future;
    await tester.pumpWidget(reviewApp(repo));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    pending.completeError(
      const NetworkException('Sin conexión con el servidor.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión con el servidor.'), findsOneWidget);
    repo.onRead = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reviewed-text')), findsOneWidget);
    expect(repo.reads, 2);
  });
  for (final type in [
    'READING_WRITING',
    'READING_SPEAKING',
    'LISTENING_WRITING',
    'LISTENING_SPEAKING',
    'MULTIPLE_CHOICE',
    'ORDER_SYLLABLES',
  ]) {
    testWidgets('entry point respects exercise type $type', (tester) async {
      final repo = ReviewRepositoryFake(reviewFrom(exerciseJson(type: type)));
      await tester.pumpWidget(
        MaterialApp(
          home: AttemptReviewPage(
            assessmentRepository: repo,
            attemptId: 'attempt-1',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Revisar manualmente'),
        type.startsWith('READING_') ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('unfinished assessment has no manual review entry', (
    tester,
  ) async {
    final repo = ReviewRepositoryFake(
      reviewFrom(exerciseJson(), status: 'IN_PROGRESS'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AttemptReviewPage(
          assessmentRepository: repo,
          attemptId: 'attempt-1',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Revisar manualmente'), findsNothing);
  });

  testWidgets(
    'Writing shows evidence texts, distinct scores and mandatory observation',
    (tester) async {
      final repo = ReviewRepositoryFake(reviewFrom(exerciseJson()));
      await tester.pumpWidget(reviewApp(repo));
      await tester.pumpAndSettle();
      expect(find.text('Texto OCR automático'), findsOneWidget);
      expect(find.text('Texto esperado'), findsOneWidget);
      expect(
        find.textContaining('Automático original\nNo disponible'),
        findsWidgets,
      );
      expect(find.textContaining('Vigente\n63.5 / 100'), findsOneWidget);
      expect(
        find.textContaining('La imagen no está disponible'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<PrimaryButton>(find.byKey(const Key('save-review')))
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const Key('reviewed-text')),
        'Mi casa es azul.',
      );
      await tester.pump();
      expect(
        tester
            .widget<PrimaryButton>(find.byKey(const Key('save-review')))
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const Key('review-observation')),
        'Verificado en imagen',
      );
      await tester.pump();
      expect(
        tester
            .widget<PrimaryButton>(find.byKey(const Key('save-review')))
            .onPressed,
        isNotNull,
      );
      expect(find.byKey(const Key('override-accuracy_score')), findsNothing);
    },
  );

  testWidgets(
    'Speaking exposes four override fields and lexical match is read-only',
    (tester) async {
      final repo = ReviewRepositoryFake(
        reviewFrom(exerciseJson(type: 'READING_SPEAKING')),
      );
      await tester.pumpWidget(reviewApp(repo));
      await tester.pumpAndSettle();
      expect(find.text('Transcripción automática (Whisper)'), findsOneWidget);
      expect(find.text('Texto reconocido por Azure'), findsOneWidget);
      expect(find.byKey(const Key('override-accuracy_score')), findsOneWidget);
      expect(find.byKey(const Key('override-fluency_score')), findsOneWidget);
      expect(
        find.byKey(const Key('override-pronunciation_score')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('override-completeness_score')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('override-lexical_match')), findsNothing);
      await tester.enterText(
        find.byKey(const Key('override-accuracy_score')),
        '101',
      );
      await tester.pump();
      expect(find.text('Ingresa un número de 0 a 100.'), findsOneWidget);
    },
  );

  testWidgets('dirty back asks before discarding a draft', (tester) async {
    final repo = ReviewRepositoryFake(reviewFrom(exerciseJson()));
    await tester.pumpWidget(reviewApp(repo));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('reviewed-text')), 'Borrador');
    await tester.pump();
    final context = tester.element(find.byType(ManualReviewPage));
    await Navigator.of(context).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Cambios sin guardar'), findsOneWidget);
    await tester.tap(find.text('Seguir editando'));
    await tester.pumpAndSettle();
    expect(find.byType(ManualReviewPage), findsOneWidget);
    await Navigator.of(context).maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar cambios'));
    await tester.pumpAndSettle();
    expect(find.text('Pantalla anterior'), findsOneWidget);
    expect(repo.requests, isEmpty);
  });

  testWidgets(
    'revert confirmation can be cancelled and history stays human readable',
    (tester) async {
      final json = exerciseJson(version: 5)..['review_status'] = 'overridden';
      json['manual_review_history'] = [
        {
          'action': 'correct_evidence',
          'review_version': 5,
          'teacher_id': 'teacher-1',
          'teacher_observation': 'Verifiqué la imagen',
          'created_at': '2026-09-20T10:00:00Z',
          'corrections': {'recognized_text': 'Mi casa es azul.'},
        },
      ];
      final repo = ReviewRepositoryFake(reviewFrom(json));
      await tester.pumpWidget(reviewApp(repo));
      await tester.pumpAndSettle();
      expect(find.text('Ajustado manualmente'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('review-observation')),
        'Restaurar',
      );
      await tester.ensureVisible(find.byKey(const Key('revert-review')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('revert-review')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(repo.requests, isEmpty);
      await tester.ensureVisible(find.text('Historial de revisiones'));
      await tester.tap(find.text('Historial de revisiones'));
      await tester.pumpAndSettle();
      expect(find.text('Corrección de texto'), findsOneWidget);
      expect(find.text('Verifiqué la imagen'), findsOneWidget);
    },
  );

  testWidgets(
    'detail fetches refreshed score when returning from manual review',
    (tester) async {
      final repo = ReviewRepositoryFake(reviewFrom(exerciseJson()));
      await tester.pumpWidget(
        MaterialApp(
          home: AttemptReviewPage(
            assessmentRepository: repo,
            attemptId: 'attempt-1',
          ),
          routes: {
            AppRoutes.manualReview: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  final json = exerciseJson(version: 4)..['score'] = 95.0;
                  repo.current = reviewFrom(json, score: 95.0);
                  Navigator.pop(context, true);
                },
                child: const Text('Guardar y volver'),
              ),
            ),
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Revisar manualmente'));
      await tester.tap(find.text('Revisar manualmente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar y volver'));
      await tester.pumpAndSettle();
      expect(repo.reads, 2);
      expect(find.text('95.0%'), findsWidgets);
      expect(find.text('Ver revisión manual'), findsOneWidget);
    },
  );

  testWidgets('Writing and Speaking fit a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final type in ['READING_WRITING', 'READING_SPEAKING']) {
      final repo = ReviewRepositoryFake(reviewFrom(exerciseJson(type: type)));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(reviewApp(repo, textScale: 1.4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Historial de revisiones'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('image evidence opens an accessible zoom and pan viewer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReviewImagePreview(url: 'https://example.invalid/evidence.png'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ReviewImagePreview));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(
      tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).maxScale,
      5,
    );
    await tester.tap(find.byTooltip('Cerrar imagen'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
