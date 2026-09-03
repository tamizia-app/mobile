class DashboardSummary {
  const DashboardSummary({
    required this.totalStudents,
    required this.totalClassrooms,
    required this.totalTemplates,
    required this.totalAssessments,
    required this.completedAttempts,
    required this.inProgressAttempts,
  });

  final int totalStudents;
  final int totalClassrooms;
  final int totalTemplates;
  final int totalAssessments;
  final int completedAttempts;
  final int inProgressAttempts;
}
