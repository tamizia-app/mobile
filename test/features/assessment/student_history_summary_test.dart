import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/features/assessment/domain/models/student_assessment_history.dart';
import 'package:tamizai_app/features/assessment/domain/repositories/assessment_repository.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/student_history_page.dart';

StudentHistoryItem attempt(
  int day,
  double? score, {
  String status = 'COMPLETED',
}) {
  return StudentHistoryItem(
    attemptId: 'attempt-$day',
    assessmentId: 'assessment',
    assessmentName: 'Evaluación de lectoescritura',
    status: status,
    completedAt: DateTime(2026, 9, day),
    finalScore: score,
  );
}

StudentAssessmentHistory historyOf(List<StudentHistoryItem> items) {
  return StudentAssessmentHistory(
    studentId: 'student',
    summary: const StudentHistorySummary(
      attemptsCount: 0,
      completedAttemptsCount: 0,
    ),
    items: items,
    chartPoints: items
        .map(
          (item) => StudentHistoryChartPoint(
            attemptId: item.attemptId,
            assessmentId: item.assessmentId,
            completedAt: item.completedAt,
            finalScore: item.finalScore,
          ),
        )
        .toList(),
  );
}

void main() {
  test('uses completion dates despite descending or unordered API items', () {
    final items = [attempt(11, 60), attempt(7, 20), attempt(9, 50)];
    final summary = historyOf(items).summaryForLoadedAttempts;
    expect(summary.latestScore, 60);
    expect(summary.trendPercentage, 20);
    expect(summary.averageScore, closeTo(43.3333, 0.001));
    expect(summary.bestScore, 60);
    expect(summary.lowestScore, 20);
    expect(summary.latestCompletedAt, DateTime(2026, 9, 11));
    expect(items.first.attemptId, 'attempt-11');
  });

  test(
    'excludes unscored and unfinished attempts and retains real zero scores',
    () {
      final summary = historyOf([
        attempt(11, null),
        attempt(10, 100, status: 'IN_PROGRESS'),
        attempt(9, 0),
        attempt(8, 50),
      ]).summaryForLoadedAttempts;
      expect(summary.completedAttemptsCount, 2);
      expect(summary.latestScore, 0);
      expect(summary.averageScore, 25);
      expect(summary.trendPercentage, -100);
    },
  );

  test(
    'does not invent variation for empty, single, or zero-baseline history',
    () {
      expect(historyOf([]).summaryForLoadedAttempts.latestScore, isNull);
      expect(
        historyOf([attempt(1, 50)]).summaryForLoadedAttempts.trendPercentage,
        isNull,
      );
      expect(
        historyOf([
          attempt(2, 50),
          attempt(1, 0),
        ]).summaryForLoadedAttempts.trendPercentage,
        isNull,
      );
      expect(
        historyOf([
          attempt(2, 50),
          attempt(1, 50),
        ]).summaryForLoadedAttempts.trendPercentage,
        0,
      );
    },
  );

  testWidgets('history explains scores and relative change on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: StudentHistoryPage(
          assessmentRepository: _HistoryRepository(
            historyOf([attempt(11, 60), attempt(9, 50)]),
          ),
          studentId: 'student',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('80 de 100 puntos'), findsOneWidget);
    expect(find.text('+20.0%'), findsOneWidget);
    expect(find.textContaining('10 puntos porcentuales'), findsOneWidget);
    await tester.ensureVisible(find.text('Puntajes por intento (%)'));
    await tester.pumpAndSettle();
  });
}

class _HistoryRepository implements AssessmentRepository {
  _HistoryRepository(this.history);
  final StudentAssessmentHistory history;

  @override
  Future<StudentAssessmentHistory> getStudentHistory(
    String studentId, {
    int? limit,
    int? offset,
    String? status,
    String? assessmentId,
    String? dateFrom,
    String? dateTo,
  }) async => history;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
