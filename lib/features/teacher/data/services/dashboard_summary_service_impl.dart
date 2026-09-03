import '../../domain/models/dashboard_summary.dart';
import '../datasources/dashboard_remote_data_source.dart';
import 'dashboard_summary_service.dart';

class DashboardSummaryServiceImpl implements DashboardSummaryService {
  const DashboardSummaryServiceImpl({
    required DashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final dto = await _remoteDataSource.getSummary();
    return dto.toDomain();
  }
}
