import '../models/assessment_attempt_dto.dart';
import '../models/assessment_dto.dart';
import '../models/assessment_response_dto.dart';
import '../models/assessment_result_dto.dart';
import '../models/assessment_template_dto.dart';

abstract interface class AssessmentRemoteDataSource {
  Future<List<AssessmentTemplateDto>> getTemplates();

  Future<AssessmentTemplateDto> getTemplateById(String templateId);

  Future<AssessmentDto> createAssessment({
    required String classroomId,
    required String templateId,
  });

  Future<List<AssessmentAttemptDto>> getAttempts(String assessmentId);

  Future<AssessmentAttemptDto> startAttempt({
    required String assessmentId,
    required String studentId,
  });

  Future<AssessmentAttemptDto> getAttemptById(String attemptId);

  Future<MCResponseDto?> getMCResponse(String exerciseAttemptId);

  Future<MCResponseDto> submitMCResponse({
    required String exerciseAttemptId,
    required String selectedOptionId,
  });

  Future<OSResponseDto?> getOSResponse(String exerciseAttemptId);

  Future<OSResponseDto> submitOSResponse({
    required String exerciseAttemptId,
    required List<String> selectedSyllables,
    required String? formedWord,
  });

  Future<SpeakingResponseDto?> getSpeakingResponse(String exerciseAttemptId);

  Future<SpeakingResponseDto> uploadSpeakingResponse({
    required String exerciseAttemptId,
    required String filePath,
  });

  Future<WritingResponseDto?> getWritingResponse(String exerciseAttemptId);

  Future<WritingResponseDto> uploadWritingResponse({
    required String exerciseAttemptId,
    required String filePath,
    required String? payloadJson,
  });

  Future<AssessmentResultDto> finishAttempt(String attemptId);

  Future<AssessmentResultDto> getResult(String attemptId);

  Future<Uri> getResponseDownloadUrl(String exerciseAttemptId);
}
