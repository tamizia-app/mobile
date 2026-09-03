import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/teacher_profile_dto.dart';
import '../models/update_teacher_profile_request_dto.dart';
import 'teacher_remote_data_source.dart';

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  const TeacherRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<TeacherProfileDto> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/teachers/me',
      );
      return TeacherProfileDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<TeacherProfileDto> updateMyProfile(
    UpdateTeacherProfileRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/v1/teachers/me',
        data: request.toJson(),
      );
      return TeacherProfileDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
}
