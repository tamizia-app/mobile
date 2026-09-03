import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/features/assessment/data/models/student_assessment_history_dto.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_attempt.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_attempt_preview.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_template.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_attempt_preview_page.dart';
import 'package:tamizai_app/features/classrooms/domain/models/classroom.dart';
import 'package:tamizai_app/features/students/domain/models/student.dart';

void main() {
  test('replaces the backend Untitled placeholder with the UI fallback', () {
    final history = StudentAssessmentHistoryDto.fromJson({
      'student_id': 'student-id',
      'summary': <String, dynamic>{},
      'chart_points': [
        {
          'attempt_id': 'attempt-id',
          'assessment_id': 'assessment-id',
          'assessment_name': 'Untitled',
        },
      ],
      'items': [
        {
          'attempt_id': 'attempt-id',
          'assessment_id': 'assessment-id',
          'assessment_name': 'Untitled',
          'status': 'COMPLETED',
        },
      ],
    }).toDomain();

    expect(history.chartPoints.single.assessmentName, isNull);
    expect(history.items.single.assessmentName, isNull);
  });

  test('preserves a real assessment name from the backend', () {
    final history = StudentAssessmentHistoryDto.fromJson({
      'student_id': 'student-id',
      'summary': <String, dynamic>{},
      'items': [
        {
          'attempt_id': 'attempt-id',
          'assessment_id': 'assessment-id',
          'assessment_name': 'Tamizaje de lectura',
          'status': 'COMPLETED',
        },
      ],
    }).toDomain();

    expect(history.items.single.assessmentName, 'Tamizaje de lectura');
  });

  testWidgets('shows exercise titles from the selected template', (
    tester,
  ) async {
    final now = DateTime(2026);
    final preview = AssessmentAttemptPreview(
      classroom: Classroom(
        classroomId: 'classroom-id',
        homeroomTeacherId: 'teacher-id',
        name: 'H52',
        gradeLevel: '10',
        section: 'A',
        schoolYear: now,
      ),
      student: Student(
        studentId: 'student-id',
        classroomId: 'classroom-id',
        code: 'EST-001',
        age: 10,
        gender: 'BOY',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      template: const AssessmentTemplate(
        templateId: 'template-id',
        name: 'Tamizaje',
        exercises: [
          TemplateExerciseSummary(
            exerciseId: 'exercise-1',
            title: 'Lectura en voz alta',
            type: 'READING_SPEAKING',
          ),
          TemplateExerciseSummary(
            exerciseId: 'exercise-2',
            title: 'Arma la palabra',
            type: 'ORDER_SYLLABLES',
          ),
        ],
      ),
      assessment: const Assessment(
        assessmentId: 'assessment-id',
        classroomId: 'classroom-id',
        templateId: 'template-id',
      ),
      attempt: const AssessmentAttempt(
        attemptId: 'attempt-id',
        assessmentId: 'assessment-id',
        studentId: 'student-id',
        status: 'IN_PROGRESS',
        exerciseAttempts: [
          ExerciseAttempt(
            exerciseAttemptId: 'exercise-attempt-1',
            exerciseId: 'exercise-1',
          ),
          ExerciseAttempt(exerciseAttemptId: 'exercise-attempt-2'),
        ],
      ),
      hasValidConsent: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(arguments: preview),
          builder: (_) => const AssessmentAttemptPreviewPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lectura en voz alta'), findsOneWidget);
    expect(find.text('Arma la palabra'), findsOneWidget);
    expect(find.text('Ejercicio 1'), findsNothing);
    expect(find.text('Ejercicio 2'), findsNothing);
  });
}
