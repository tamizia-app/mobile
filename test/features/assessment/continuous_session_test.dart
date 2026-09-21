import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/constants/app_routes.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/core/widgets/selectable_word_card.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_attempt.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_response.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_result.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/attempt_session_page.dart';
import 'manual_review_fixtures.dart';

Widget _app(_SessionRepository repo) => MaterialApp(
  onGenerateRoute: (settings) => MaterialPageRoute<void>(
    settings: RouteSettings(name: settings.name, arguments: 'attempt-1'),
    builder: (_) => settings.name == AppRoutes.assessmentResult
        ? const Scaffold(body: Text('Resultado final'))
        : AttemptSessionPage(assessmentRepository: repo),
  ),
);

Future<void> _answer(WidgetTester tester) async {
  await tester.tap(find.text('Casa'));
  await tester.ensureVisible(find.text('Guardar respuesta'));
  await tester.tap(find.text('Guardar respuesta'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'starts immediately, advances directly and finishes after last answer',
    (tester) async {
      final repo = _SessionRepository();
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 1'), findsOneWidget);
      expect(find.text('Abrir ejercicio'), findsNothing);
      expect(find.text('Finalizar intento'), findsNothing);
      await _answer(tester);
      expect(find.text('Pregunta 2'), findsOneWidget);
      expect(repo.finishes, 0);
      await _answer(tester);
      expect(find.text('Resultado final'), findsOneWidget);
      expect(repo.submitted, ['ea-1', 'ea-2']);
      expect(repo.finishes, 1);
    },
  );

  testWidgets('header and system back offer finish; continue preserves draft', (
    tester,
  ) async {
    final repo = _SessionRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('¿Desea finalizar la prueba?'), findsOneWidget);
    await tester.tap(find.text('No, continuar'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SelectableWordCard>(find.byType(SelectableWordCard))
          .selected,
      isTrue,
    );
    expect(repo.finishes, 0);
    await Navigator.of(
      tester.element(find.byType(AttemptSessionPage)),
    ).maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí, finalizar'));
    await tester.pumpAndSettle();
    expect(repo.finishes, 1);
    expect(repo.submitted, isEmpty);
    expect(find.text('Resultado final'), findsOneWidget);
  });

  testWidgets(
    'failed early finish keeps current exercise and selected answer',
    (tester) async {
      final repo = _SessionRepository()..failFinish = true;
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Casa'));
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sí, finalizar'));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 1'), findsOneWidget);
      expect(
        tester
            .widget<SelectableWordCard>(find.byType(SelectableWordCard))
            .selected,
        isTrue,
      );
      expect(find.text('Sin conexión'), findsOneWidget);
    },
  );

  testWidgets(
    'failed final finish retries finish without resubmitting last answer',
    (tester) async {
      final repo = _SessionRepository()..failFinish = true;
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await _answer(tester);
      await _answer(tester);
      expect(find.text('No pudimos finalizar la prueba'), findsOneWidget);
      repo.failFinish = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(repo.submitted.length, 2);
      expect(repo.finishes, 2);
      expect(find.text('Resultado final'), findsOneWidget);
    },
  );

  testWidgets('back cannot finish while an answer is being submitted', (
    tester,
  ) async {
    final repo = _SessionRepository()..submission = Completer<MCResponse>();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.ensureVisible(find.text('Guardar respuesta'));
    await tester.tap(find.text('Guardar respuesta'));
    await tester.pump();
    await Navigator.of(
      tester.element(find.byType(AttemptSessionPage)),
    ).maybePop();
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    repo.submission!.complete(
      const MCResponse(
        responseId: 'r',
        exerciseAttemptId: 'ea-1',
        selectedOptionId: 'o',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pregunta 2'), findsOneWidget);
  });
}

class _SessionRepository extends ReviewRepositoryFake {
  _SessionRepository() : super(reviewFrom(exerciseJson()));
  final submitted = <String>[];
  int finishes = 0;
  bool failFinish = false;
  Completer<MCResponse>? submission;
  @override
  Future<AssessmentAttempt> getAttemptById(String id) async =>
      AssessmentAttempt(
        attemptId: id,
        assessmentId: 'a',
        studentId: 's',
        status: 'IN_PROGRESS',
        exerciseAttempts: [
          for (var i = 1; i <= 2; i++)
            ExerciseAttempt(
              exerciseAttemptId: 'ea-$i',
              type: 'MULTIPLE_CHOICE',
              status: 'PENDING',
              prompt: 'Pregunta $i',
              mcOptions: const [
                MCOption(optionId: 'o', text: 'Casa', orderIndex: 1),
              ],
            ),
        ],
      );
  @override
  Future<MCResponse?> getMCResponse(String id) async => null;
  @override
  Future<MCResponse> submitMCResponse({
    required String exerciseAttemptId,
    required String selectedOptionId,
  }) async {
    submitted.add(exerciseAttemptId);
    return submission == null
        ? MCResponse(
            responseId: 'r',
            exerciseAttemptId: exerciseAttemptId,
            selectedOptionId: selectedOptionId,
          )
        : await submission!.future;
  }

  @override
  Future<AssessmentResult> finishAttempt(String id) async {
    finishes++;
    if (failFinish) throw const NetworkException('Sin conexión');
    return AssessmentResult(attemptId: id, finalScore: 80);
  }

  @override
  Future<AssessmentResult> getResult(String id) async =>
      throw const NetworkException('Sin conexión');
}
