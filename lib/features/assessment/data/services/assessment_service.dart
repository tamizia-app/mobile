import '../../domain/models/assessment_session.dart';

abstract class AssessmentService {
  Future<AssessmentSession> createSession({
    required String classroomId,
    required String studentId,
    required String exerciseId,
  });

  Future<void> startSession(String sessionId);

  Future<void> pauseSession(String sessionId);

  Future<void> resumeSession(String sessionId);

  Future<void> cancelSession(String sessionId);

  Future<void> finishSession(String sessionId);

  Future<void> saveReadingEvidence(String sessionId);

  Future<void> saveWritingEvidence(String sessionId);
}
