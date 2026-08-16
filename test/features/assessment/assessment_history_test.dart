import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/features/assessment/data/models/student_assessment_history_dto.dart';

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
}
