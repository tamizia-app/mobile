class DashboardSummary {
  const DashboardSummary({
    required this.classrooms,
    required this.students,
    required this.evaluations,
    required this.suggestedReviews,
  });

  final int classrooms;
  final int students;
  final int evaluations;
  final int suggestedReviews;
}
