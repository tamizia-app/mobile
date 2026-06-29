import '../models/assessment.dart';
import '../models/assessment_attempt.dart';
import '../models/assessment_response.dart';
import '../models/assessment_result.dart';
import '../models/assessment_template.dart';

abstract interface class AssessmentRepository {
  Future<List<AssessmentTemplate>> getTemplates();

  Future<AssessmentTemplate> getTemplateById(String templateId);

  Future<Assessment> createAssessment({
    required String classroomId,
    required String templateId,
  });

  Future<List<AssessmentAttempt>> getAttempts(String assessmentId);

  Future<AssessmentAttempt> startAttempt({
    required String assessmentId,
    required String studentId,
  });

  Future<AssessmentAttempt> getAttemptById(String attemptId);

  Future<MCResponse?> getMCResponse(String exerciseAttemptId);

  Future<MCResponse> submitMCResponse({
    required String exerciseAttemptId,
    required String selectedOptionId,
  });

  Future<OSResponse?> getOSResponse(String exerciseAttemptId);

  Future<OSResponse> submitOSResponse({
    required String exerciseAttemptId,
    required List<String> selectedSyllables,
    required String? formedWord,
  });

  Future<SpeakingResponse?> getSpeakingResponse(String exerciseAttemptId);

  Future<SpeakingResponse> uploadSpeakingResponse({
    required String exerciseAttemptId,
    required String filePath,
  });

  Future<WritingResponse?> getWritingResponse(String exerciseAttemptId);

  Future<WritingResponse> uploadWritingResponse({
    required String exerciseAttemptId,
    required String filePath,
    required String? payloadJson,
  });

  Future<AssessmentResult> finishAttempt(String attemptId);

  Future<AssessmentResult> getResult(String attemptId);

  Future<Uri> getResponseDownloadUrl(String exerciseAttemptId);
}
