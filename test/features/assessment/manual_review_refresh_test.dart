import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/constants/app_routes.dart';
import 'package:tamizai_app/features/assessment/data/models/student_assessment_history_dto.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_result.dart';
import 'package:tamizai_app/features/assessment/domain/models/student_assessment_history.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_result_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/student_history_page.dart';
import 'manual_review_fixtures.dart';

void main() {
  testWidgets(
    'result screen reloads score and intervention level after closing detail',
    (tester) async {
      final repo = _RefreshRepository();
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: const RouteSettings(
              arguments: AssessmentResult(
                attemptId: 'attempt-1',
                finalScore: 30,
                interventionLevel: 'HIGH',
              ),
            ),
            builder: (_) => settings.name == AppRoutes.attemptReview
                ? _returnPage()
                : AssessmentResultPage(assessmentRepository: repo),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Docente: ver resultados'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ver detalle del intento'));
      await tester.tap(find.text('Ver detalle del intento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volver del detalle'));
      await tester.pumpAndSettle();
      expect(repo.resultReads, 1);
      expect(find.text('91.0%'), findsWidgets);
      expect(find.text('Intervención: Bajo'), findsOneWidget);
      expect(find.text('30.0%'), findsNothing);
    },
  );

  testWidgets(
    'student history reloads items and summary after closing detail',
    (tester) async {
      final repo = _RefreshRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: StudentHistoryPage(
            assessmentRepository: repo,
            studentId: 'student-1',
          ),
          routes: {AppRoutes.attemptReview: (_) => _returnPage()},
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Evaluación de lectura'));
      await tester.tap(find.text('Evaluación de lectura'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volver del detalle'));
      await tester.pumpAndSettle();
      expect(repo.historyReads, 2);
      expect(find.text('91.0%'), findsWidgets);
      expect(find.text('30.0%'), findsNothing);
    },
  );
}

Widget _returnPage() => Scaffold(
  body: Builder(
    builder: (context) => TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Volver del detalle'),
    ),
  ),
);

class _RefreshRepository extends ReviewRepositoryFake {
  _RefreshRepository() : super(reviewFrom(exerciseJson()));
  int resultReads = 0;
  int historyReads = 0;
  @override
  Future<AssessmentResult> getResult(String attemptId) async {
    resultReads++;
    return const AssessmentResult(
      attemptId: 'attempt-1',
      finalScore: 91,
      interventionLevel: 'LOW',
    );
  }

  @override
  Future<StudentAssessmentHistory> getStudentHistory(
    String studentId, {
    int? limit,
    int? offset,
    String? status,
    String? assessmentId,
    String? dateFrom,
    String? dateTo,
  }) async {
    historyReads++;
    return StudentAssessmentHistoryDto.fromJson({
      'student_id': studentId,
      'summary': <String, dynamic>{},
      'items': [
        {
          'attempt_id': 'attempt-1',
          'assessment_id': 'assessment-1',
          'assessment_name': 'Evaluación de lectura',
          'status': 'COMPLETED',
          'final_score': historyReads == 1 ? 30 : 91,
          'intervention_level': 'LOW',
          'completed_at': '2026-09-20T12:00:00Z',
        },
      ],
    }).toDomain();
  }
}
