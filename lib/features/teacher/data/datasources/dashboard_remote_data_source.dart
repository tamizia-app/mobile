import '../models/dashboard_summary_dto.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardSummaryDto> getSummary();
}
