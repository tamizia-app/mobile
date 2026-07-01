class RepeatAttemptResponse {
  const RepeatAttemptResponse({
    required this.originalAttemptId,
    required this.newAttemptId,
    required this.assessmentId,
    required this.studentId,
    required this.status,
    this.reason,
    this.exerciseAttempts = const [],
  });

  final String originalAttemptId;
  final String newAttemptId;
  final String assessmentId;
  final String studentId;
  final String status;
  final String? reason;
  final List<Map<String, dynamic>> exerciseAttempts;
}
