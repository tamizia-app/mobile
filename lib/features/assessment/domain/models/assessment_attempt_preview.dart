import '../../../classrooms/domain/models/classroom.dart';
import '../../../students/domain/models/student.dart';
import 'assessment.dart';
import 'assessment_attempt.dart';
import 'assessment_template.dart';

class AssessmentAttemptPreview {
  const AssessmentAttemptPreview({
    required this.classroom,
    required this.student,
    required this.template,
    required this.assessment,
    required this.attempt,
    required this.hasValidConsent,
    this.resumedExistingAttempt = false,
  });

  final Classroom classroom;
  final Student student;
  final AssessmentTemplate template;
  final Assessment assessment;
  final AssessmentAttempt attempt;
  final bool hasValidConsent;
  final bool resumedExistingAttempt;
}
