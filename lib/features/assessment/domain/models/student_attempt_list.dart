class StudentAttemptList {
  const StudentAttemptList({
    required this.studentId,
    this.items = const [],
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  final String studentId;
  final List<StudentAttemptListItem> items;
  final int total;
  final int limit;
  final int offset;
}

class StudentAttemptListItem {
  const StudentAttemptListItem({
    required this.attemptId,
    required this.assessmentId,
    this.assessmentName,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.finalScore,
    this.maxScore,
    this.interventionLevel,
    this.totalExercises = 0,
    this.evaluatedExercises = 0,
    this.pendingExercises = 0,
  });

  final String attemptId;
  final String assessmentId;
  final String? assessmentName;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? finalScore;
  final double? maxScore;
  final String? interventionLevel;
  final int totalExercises;
  final int evaluatedExercises;
  final int pendingExercises;
}
