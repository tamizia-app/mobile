import '../../domain/models/dashboard_summary.dart';
import 'dashboard_summary_service.dart';

class MockDashboardSummaryService implements DashboardSummaryService {
  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const DashboardSummary(
      classrooms: 12,
      students: 145,
      evaluations: 89,
      suggestedReviews: 5,
    );
  }
}
