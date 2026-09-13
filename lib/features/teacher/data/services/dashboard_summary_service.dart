import '../../domain/models/dashboard_summary.dart';

abstract class DashboardSummaryService {
  Future<DashboardSummary> getDashboardSummary();
}
