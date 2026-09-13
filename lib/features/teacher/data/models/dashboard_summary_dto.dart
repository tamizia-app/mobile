import '../../domain/models/dashboard_summary.dart';

class DashboardSummaryDto {
  const DashboardSummaryDto({
    required this.totalStudents,
    required this.totalClassrooms,
    required this.totalTemplates,
    required this.totalAssessments,
    required this.completedAttempts,
    required this.inProgressAttempts,
  });

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryDto(
      totalStudents: json['total_students'] as int? ?? 0,
      totalClassrooms: json['total_classrooms'] as int? ?? 0,
      totalTemplates: json['total_templates'] as int? ?? 0,
      totalAssessments: json['total_assessments'] as int? ?? 0,
      completedAttempts: json['completed_attempts'] as int? ?? 0,
      inProgressAttempts: json['in_progress_attempts'] as int? ?? 0,
    );
  }

  final int totalStudents;
  final int totalClassrooms;
  final int totalTemplates;
  final int totalAssessments;
  final int completedAttempts;
  final int inProgressAttempts;

  DashboardSummary toDomain() {
    return DashboardSummary(
      totalStudents: totalStudents,
      totalClassrooms: totalClassrooms,
      totalTemplates: totalTemplates,
      totalAssessments: totalAssessments,
      completedAttempts: completedAttempts,
      inProgressAttempts: inProgressAttempts,
    );
  }
}
