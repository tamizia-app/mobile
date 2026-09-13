import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/theme/app_theme.dart';
import 'package:tamizai_app/features/assessment/domain/models/exercise_integrity.dart';
import 'package:tamizai_app/features/assessment/presentation/widgets/exercise_metrics_panel.dart';

void main() {
  Future<void> pumpMetrics(
    WidgetTester tester,
    ScoringComponents metrics, {
    bool writing = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseMetricsPanel(metrics: metrics, writing: writing),
          ),
        ),
      ),
    );
  }

  testWidgets('error rates keep their scale and values above 100 percent', (
    tester,
  ) async {
    await pumpMetrics(
      tester,
      const ScoringComponents(
        confidenceAvg: 0.948,
        cer: 0.071,
        wer: 1.25,
        similarityScore: 86.35,
      ),
    );
    expect(find.text('94.8%'), findsOneWidget);
    expect(find.text('7.1%'), findsOneWidget);
    expect(find.text('125.0%'), findsOneWidget);
    expect(find.text('86.3 / 100'), findsOneWidget);
    expect(find.text('Menor valor: menos diferencias'), findsNWidgets(2));
    expect(
      find.textContaining('No mide la habilidad del estudiante'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'missing metrics stay unavailable and are never displayed as zero',
    (tester) async {
      await pumpMetrics(tester, const ScoringComponents());
      expect(find.text('No disponible'), findsNWidgets(4));
      expect(find.text('0.0%'), findsNothing);
      expect(find.text('0.0 / 100'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'zero is a real measurement and speaking scores are not multiplied',
    (tester) async {
      await pumpMetrics(
        tester,
        const ScoringComponents(
          pronunciationScore: 85.2,
          accuracyScore: 0,
          prosodyScore: 72,
        ),
        writing: false,
      );
      expect(find.text('85.2 / 100'), findsOneWidget);
      expect(find.text('0.0 / 100'), findsOneWidget);
      expect(find.text('Prosodia'), findsOneWidget);
      expect(find.text('72.0 / 100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
