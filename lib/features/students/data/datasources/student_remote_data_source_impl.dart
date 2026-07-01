import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/create_student_request_dto.dart';
import '../models/download_url_dto.dart';
import '../models/student_consent_dto.dart';
import '../models/student_dto.dart';
import '../models/update_student_request_dto.dart';
import 'student_remote_data_source.dart';

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  const StudentRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<StudentDto>> getAllStudents() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/v1/students',
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid students response.');
      }
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid student response.');
            }
            return StudentDto.fromJson(item);
          })
          .toList(growable: false);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<List<StudentDto>> getStudentsByClassroom(String classroomId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/v1/classrooms/$classroomId/students',
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid students response.');
      }
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid student response.');
            }
            return StudentDto.fromJson(item);
          })
          .toList(growable: false);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<StudentDto> createStudent(
    String classroomId,
    CreateStudentRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/classrooms/$classroomId/students',
        data: request.toJson(),
      );
      return StudentDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<StudentDto> getStudentById(String studentId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/students/$studentId',
      );
      return StudentDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<StudentDto> updateStudent(
    String studentId,
    UpdateStudentRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/v1/students/$studentId',
        data: request.toJson(),
      );
      return StudentDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    try {
      await _apiClient.dio.delete<void>('/api/v1/students/$studentId');
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<StudentConsentDto> getConsent(String studentId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/students/$studentId/consent',
      );
      return StudentConsentDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<StudentConsentDto> revokeConsent(String studentId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/students/$studentId/consent/revoke',
      );
      return StudentConsentDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<StudentConsentDto> uploadConsent(
    String studentId, {
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final data = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/students/$studentId/consent/upload',
        data: data,
      );
      return StudentConsentDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<DownloadUrlDto> getConsentTemplateDownloadUrl() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/students/consent/template',
      );
      return DownloadUrlDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<DownloadUrlDto> getConsentDownloadUrl(String studentId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/students/$studentId/consent/download',
      );
      return DownloadUrlDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
}
