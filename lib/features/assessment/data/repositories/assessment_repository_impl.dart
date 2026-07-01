import '../../domain/models/assessment.dart';
import '../../domain/models/assessment_attempt.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/models/assessment_result.dart';
import '../../domain/models/assessment_template.dart';
import '../../domain/models/attempt_review.dart';
import '../../domain/models/repeat_attempt_response.dart';
import '../../domain/models/student_assessment_history.dart';
import '../../domain/models/student_attempt_list.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/assessment_remote_data_source.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  const AssessmentRepositoryImpl({
    required AssessmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AssessmentRemoteDataSource _remoteDataSource;

  @override
  Future<List<AssessmentTemplate>> getTemplates() async {
    final response = await _remoteDataSource.getTemplates();
    return response.map((item) => item.toDomain()).toList(growable: false);
  }

  @override
  Future<AssessmentTemplate> getTemplateById(String templateId) async {
    final response = await _remoteDataSource.getTemplateById(templateId);
    return response.toDomain();
  }

  @override
  Future<Assessment> createAssessment({
    required String classroomId,
    required String templateId,
  }) async {
    final response = await _remoteDataSource.createAssessment(
      classroomId: classroomId,
      templateId: templateId,
    );
    return response.toDomain(
      classroomIdFallback: classroomId,
      templateIdFallback: templateId,
    );
  }

  @override
  Future<List<AssessmentAttempt>> getAttempts(String assessmentId) async {
    final response = await _remoteDataSource.getAttempts(assessmentId);
    return response
        .map(
          (item) => item.toDomain(
            assessmentIdFallback: assessmentId,
            studentIdFallback: '',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<AssessmentAttempt> startAttempt({
    required String assessmentId,
    required String studentId,
  }) async {
    final response = await _remoteDataSource.startAttempt(
      assessmentId: assessmentId,
      studentId: studentId,
    );
    return response.toDomain(
      assessmentIdFallback: assessmentId,
      studentIdFallback: studentId,
    );
  }

  @override
  Future<AssessmentAttempt> getAttemptById(String attemptId) async {
    final response = await _remoteDataSource.getAttemptById(attemptId);
    return response.toDomain(assessmentIdFallback: '', studentIdFallback: '');
  }

  @override
  Future<MCResponse?> getMCResponse(String exerciseAttemptId) async {
    final response = await _remoteDataSource.getMCResponse(exerciseAttemptId);
    return response?.toDomain();
  }

  @override
  Future<MCResponse> submitMCResponse({
    required String exerciseAttemptId,
    required String selectedOptionId,
  }) async {
    final response = await _remoteDataSource.submitMCResponse(
      exerciseAttemptId: exerciseAttemptId,
      selectedOptionId: selectedOptionId,
    );
    return response.toDomain();
  }

  @override
  Future<OSResponse?> getOSResponse(String exerciseAttemptId) async {
    final response = await _remoteDataSource.getOSResponse(exerciseAttemptId);
    return response?.toDomain();
  }

  @override
  Future<OSResponse> submitOSResponse({
    required String exerciseAttemptId,
    required List<String> selectedSyllables,
    required String? formedWord,
  }) async {
    final response = await _remoteDataSource.submitOSResponse(
      exerciseAttemptId: exerciseAttemptId,
      selectedSyllables: selectedSyllables,
      formedWord: formedWord,
    );
    return response.toDomain();
  }

  @override
  Future<SpeakingResponse?> getSpeakingResponse(
    String exerciseAttemptId,
  ) async {
    final response = await _remoteDataSource.getSpeakingResponse(
      exerciseAttemptId,
    );
    return response?.toDomain();
  }

  @override
  Future<SpeakingResponse> uploadSpeakingResponse({
    required String exerciseAttemptId,
    required String filePath,
  }) async {
    final response = await _remoteDataSource.uploadSpeakingResponse(
      exerciseAttemptId: exerciseAttemptId,
      filePath: filePath,
    );
    return response.toDomain();
  }

  @override
  Future<WritingResponse?> getWritingResponse(String exerciseAttemptId) async {
    final response = await _remoteDataSource.getWritingResponse(
      exerciseAttemptId,
    );
    return response?.toDomain();
  }

  @override
  Future<WritingResponse> uploadWritingResponse({
    required String exerciseAttemptId,
    required String filePath,
    required String? payloadJson,
  }) async {
    final response = await _remoteDataSource.uploadWritingResponse(
      exerciseAttemptId: exerciseAttemptId,
      filePath: filePath,
      payloadJson: payloadJson,
    );
    return response.toDomain();
  }

  @override
  Future<AssessmentResult> finishAttempt(String attemptId) async {
    final response = await _remoteDataSource.finishAttempt(attemptId);
    return response.toDomain();
  }

  @override
  Future<AssessmentResult> getResult(String attemptId) async {
    final response = await _remoteDataSource.getResult(attemptId);
    return response.toDomain();
  }

  @override
  Future<Uri> getResponseDownloadUrl(String exerciseAttemptId) {
    return _remoteDataSource.getResponseDownloadUrl(exerciseAttemptId);
  }

  @override
  Future<StudentAssessmentHistory> getStudentHistory(
    String studentId, {
    int? limit,
    int? offset,
    String? status,
    String? assessmentId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _remoteDataSource.getStudentHistory(
      studentId,
      limit: limit,
      offset: offset,
      status: status,
      assessmentId: assessmentId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return response.toDomain();
  }

  @override
  Future<StudentAttemptList> getAttemptsByStudent(
    String studentId, {
    int? limit,
    int? offset,
    String? status,
    String? assessmentId,
  }) async {
    final response = await _remoteDataSource.getAttemptsByStudent(
      studentId,
      limit: limit,
      offset: offset,
      status: status,
      assessmentId: assessmentId,
    );
    return response.toDomain();
  }

  @override
  Future<AttemptReview> getAttemptReview(String attemptId) async {
    final response = await _remoteDataSource.getAttemptReview(attemptId);
    return response.toDomain();
  }

  @override
  Future<RepeatAttemptResponse> repeatAttempt(
    String attemptId, {
    String? reason,
  }) async {
    final response = await _remoteDataSource.repeatAttempt(
      attemptId,
      reason: reason,
    );
    return response.toDomain();
  }
}
