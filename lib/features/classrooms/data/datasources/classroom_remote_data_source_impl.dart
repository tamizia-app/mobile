import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/classroom_dto.dart';
import '../models/create_classroom_request_dto.dart';
import '../models/update_classroom_request_dto.dart';
import 'classroom_remote_data_source.dart';

class ClassroomRemoteDataSourceImpl implements ClassroomRemoteDataSource {
  const ClassroomRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ClassroomDto>> getClassrooms() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/v1/classrooms',
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid classrooms response.');
      }
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid classroom response.');
            }
            return ClassroomDto.fromJson(item);
          })
          .toList(growable: false);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<ClassroomDto> getClassroomById(String classroomId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/classrooms/$classroomId',
      );
      return ClassroomDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<ClassroomDto> createClassroom(
    CreateClassroomRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/classrooms',
        data: request.toJson(),
      );
      return ClassroomDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<ClassroomDto> updateClassroom(
    String classroomId,
    UpdateClassroomRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/v1/classrooms/$classroomId',
        data: request.toJson(),
      );
      return ClassroomDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteClassroom(String classroomId) async {
    try {
      await _apiClient.dio.delete<void>('/api/v1/classrooms/$classroomId');
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
}
