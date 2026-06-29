import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/assessment_attempt_dto.dart';
import '../models/assessment_dto.dart';
import '../models/assessment_response_dto.dart';
import '../models/assessment_result_dto.dart';
import '../models/assessment_template_dto.dart';
import 'assessment_remote_data_source.dart';

class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  const AssessmentRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<AssessmentTemplateDto>> getTemplates() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        '/api/v1/assessments/templates',
      );
      return _readList(
        response.data,
        'templates',
      ).map(AssessmentTemplateDto.fromJson).toList(growable: false);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AssessmentTemplateDto> getTemplateById(String templateId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/templates/$templateId',
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid template response.');
      }
      return AssessmentTemplateDto.fromJson(data);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AssessmentDto> createAssessment({
    required String classroomId,
    required String templateId,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments',
        data: {'classroom_id': classroomId, 'template_id': templateId},
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid assessment response.');
      }
      return AssessmentDto.fromJson(data);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<List<AssessmentAttemptDto>> getAttempts(String assessmentId) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        '/api/v1/assessments/$assessmentId/attempts',
      );
      return _readList(
        response.data,
        'attempts',
      ).map(AssessmentAttemptDto.fromJson).toList(growable: false);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AssessmentAttemptDto> startAttempt({
    required String assessmentId,
    required String studentId,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments/$assessmentId/attempts',
        data: {'student_id': studentId},
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid attempt response.');
      }
      return AssessmentAttemptDto.fromJson(data);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AssessmentAttemptDto> getAttemptById(String attemptId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/attempts/$attemptId',
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Invalid attempt response.');
      }
      return AssessmentAttemptDto.fromJson(data);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<MCResponseDto?> getMCResponse(String exerciseAttemptId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/mc-response',
      );
      final data = response.data;
      return data == null ? null : MCResponseDto.fromJson(data);
    } catch (error) {
      final mapped = ApiErrorMapper.map(error);
      if (mapped is NotFoundException) {
        return null;
      }
      throw mapped;
    }
  }

  @override
  Future<MCResponseDto> submitMCResponse({
    required String exerciseAttemptId,
    required String selectedOptionId,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/mc-response',
        data: {'selected_option_id': selectedOptionId},
      );
      return MCResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<OSResponseDto?> getOSResponse(String exerciseAttemptId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/os-response',
      );
      final data = response.data;
      return data == null ? null : OSResponseDto.fromJson(data);
    } catch (error) {
      final mapped = ApiErrorMapper.map(error);
      if (mapped is NotFoundException) {
        return null;
      }
      throw mapped;
    }
  }

  @override
  Future<OSResponseDto> submitOSResponse({
    required String exerciseAttemptId,
    required List<String> selectedSyllables,
    required String? formedWord,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/os-response',
        data: {
          'selected_syllables': selectedSyllables,
          'formed_word': formedWord,
        },
      );
      return OSResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<SpeakingResponseDto?> getSpeakingResponse(
    String exerciseAttemptId,
  ) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/speaking-response',
      );
      final data = response.data;
      return data == null ? null : SpeakingResponseDto.fromJson(data);
    } catch (error) {
      final mapped = ApiErrorMapper.map(error);
      if (mapped is NotFoundException) {
        return null;
      }
      throw mapped;
    }
  }

  @override
  Future<SpeakingResponseDto> uploadSpeakingResponse({
    required String exerciseAttemptId,
    required String filePath,
  }) async {
    try {
      final contentType = DioMediaType('audio', 'wav');
      final fileName = _fileNameFromPath(filePath);
      await _logMultipartFile(
        label: 'speaking-response',
        filePath: filePath,
        fieldName: 'file',
        contentType: contentType.toString(),
      );
      final data = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: contentType,
        ),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/speaking-response',
        data: data,
      );
      return SpeakingResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<WritingResponseDto?> getWritingResponse(
    String exerciseAttemptId,
  ) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/writing-response',
      );
      final data = response.data;
      return data == null ? null : WritingResponseDto.fromJson(data);
    } catch (error) {
      final mapped = ApiErrorMapper.map(error);
      if (mapped is NotFoundException) {
        return null;
      }
      throw mapped;
    }
  }

  @override
  Future<WritingResponseDto> uploadWritingResponse({
    required String exerciseAttemptId,
    required String filePath,
    required String? payloadJson,
  }) async {
    try {
      final payload = <String, dynamic>{
        'file': await MultipartFile.fromFile(filePath),
      };
      if (payloadJson != null) {
        payload['payload_json'] = payloadJson;
      }
      final data = FormData.fromMap(payload);
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments/exercise-attempts/$exerciseAttemptId/writing-response',
        data: data,
      );
      return WritingResponseDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AssessmentResultDto> finishAttempt(String attemptId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/assessments/attempts/$attemptId/finish',
      );
      return AssessmentResultDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<AssessmentResultDto> getResult(String attemptId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/attempts/$attemptId/result',
      );
      return AssessmentResultDto.fromJson(response.data!);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  @override
  Future<Uri> getResponseDownloadUrl(String exerciseAttemptId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/assessments/responses/$exerciseAttemptId/download-url',
      );
      final value = response.data?['download_url'];
      if (value is! String || value.trim().isEmpty) {
        throw const FormatException('Invalid download url response.');
      }
      return Uri.parse(value);
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }

  List<Map<String, dynamic>> _readList(dynamic data, String collectionKey) {
    if (data is List) {
      return data.map(_asMap).toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final candidates = [
        data[collectionKey],
        data['items'],
        data['data'],
        data['results'],
      ];
      final list = _firstList(candidates);
      if (list != null) {
        return list.map(_asMap).toList(growable: false);
      }
    }
    throw const FormatException('Invalid list response.');
  }

  Map<String, dynamic> _asMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    }
    throw const FormatException('Invalid list item response.');
  }

  List<dynamic>? _firstList(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }
    return null;
  }

  String _fileNameFromPath(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  Future<void> _logMultipartFile({
    required String label,
    required String filePath,
    required String fieldName,
    required String contentType,
  }) async {
    if (!kDebugMode) {
      return;
    }
    final file = File(filePath);
    final size = file.existsSync() ? await file.length() : 0;
    final extension = filePath.contains('.') ? filePath.split('.').last : '';
    debugPrint(
      '$label multipart: field=$fieldName, path=$filePath, '
      'extension=$extension, sizeBytes=$size, contentType=$contentType',
    );
  }
}
