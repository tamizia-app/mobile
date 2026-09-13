import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/dashboard_summary_dto.dart';
import 'dashboard_remote_data_source.dart';

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<DashboardSummaryDto> getSummary() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/dashboard/summary',
      );
      return DashboardSummaryDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
}
