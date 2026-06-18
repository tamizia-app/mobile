import '../../../exercises/data/services/exercise_service.dart';
import '../../domain/models/assessment_session.dart';
import 'assessment_service.dart';

class MockAssessmentService implements AssessmentService {
  MockAssessmentService({required ExerciseService exerciseService})
    : _exerciseService = exerciseService;

  final ExerciseService _exerciseService;
  AssessmentSession? lastSession;

  @override
  Future<AssessmentSession> createSession({
    required String classroomId,
    required String studentId,
    required String exerciseId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final exercise = await _exerciseService.getExerciseById(exerciseId);
    lastSession = AssessmentSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      classroomId: classroomId,
      studentId: studentId,
      exerciseId: exerciseId,
      type: exercise.type,
      status: 'created',
      estimatedDurationMinutes: exercise.estimatedDurationMinutes,
    );
    return lastSession!;
  }

  @override
  Future<void> startSession(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    lastSession = lastSession?.copyWith(status: 'started');
  }

  @override
  Future<void> pauseSession(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    lastSession = lastSession?.copyWith(status: 'paused');
    // TODO: persist pause timestamp in backend so real metrics exclude paused time.
  }

  @override
  Future<void> resumeSession(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    lastSession = lastSession?.copyWith(status: 'started');
    // TODO: persist resume timestamp in backend so timing metrics stay clean.
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    lastSession = lastSession?.copyWith(status: 'cancelled');
  }

  @override
  Future<void> finishSession(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    lastSession = lastSession?.copyWith(status: 'finished');
  }

  @override
  Future<void> saveReadingEvidence(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    // TODO: capture audio evidence and send it to backend when API exists.
  }

  @override
  Future<void> saveWritingEvidence(String sessionId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    // TODO: export canvas as image, upload writing evidence to backend,
    // and process with Azure AI Vision/OCR when API exists.
  }
}

// TODO: future backend integration.
// class ApiAssessmentService implements AssessmentService {
//   // POST /api/assessment-sessions
//   // PATCH /api/assessment-sessions/{id}/start
//   // PATCH /api/assessment-sessions/{id}/pause
//   // PATCH /api/assessment-sessions/{id}/resume
//   // PATCH /api/assessment-sessions/{id}/cancel
//   // PATCH /api/assessment-sessions/{id}/finish
//   // POST /api/assessment-sessions/{id}/audio
//   // POST /api/assessment-sessions/{id}/reading-evidence
//   // POST /api/assessment-sessions/{id}/writing-evidence
// }
