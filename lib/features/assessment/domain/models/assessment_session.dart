import 'assessment_type.dart';

class AssessmentSession {
  const AssessmentSession({
    required this.id,
    required this.classroomId,
    required this.studentId,
    required this.exerciseId,
    required this.type,
    required this.status,
    required this.estimatedDurationMinutes,
  });

  final String id;
  final String classroomId;
  final String studentId;
  final String exerciseId;
  final AssessmentType type;
  final String status;
  final int estimatedDurationMinutes;

  AssessmentSession copyWith({String? status}) {
    return AssessmentSession(
      id: id,
      classroomId: classroomId,
      studentId: studentId,
      exerciseId: exerciseId,
      type: type,
      status: status ?? this.status,
      estimatedDurationMinutes: estimatedDurationMinutes,
    );
  }
}
