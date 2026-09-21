import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_attempt.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_response.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_exercise_args.dart';
import 'package:tamizai_app/features/assessment/presentation/viewmodels/writing_assessment_viewmodel.dart';
import 'manual_review_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'locked Writing evidence is not uploaded again, even if upload is called directly',
    () async {
      final repo = _LockedRepository();
      final model = WritingAssessmentViewModel(assessmentRepository: repo);
      addTearDown(model.dispose);
      model.args = const AttemptExerciseArgs(
        attemptId: 'attempt-1',
        exerciseAttempt: ExerciseAttempt(exerciseAttemptId: 'ea-1'),
        exerciseIndex: 0,
        totalExercises: 1,
      );
      model.startStroke(const Offset(10, 10));
      expect(
        await model.upload(
          imagePath: 'not-read-by-fake.png',
          canvasSize: const Size(100, 100),
        ),
        isFalse,
      );
      expect(model.isEvidenceLocked, isTrue);
      expect(model.errorMessage, 'La evidencia está bloqueada.');
      expect(
        await model.upload(
          imagePath: 'not-read-by-fake.png',
          canvasSize: const Size(100, 100),
        ),
        isFalse,
      );
      expect(repo.uploads, 1);
    },
  );
}

class _LockedRepository extends ReviewRepositoryFake {
  _LockedRepository() : super(reviewFrom(exerciseJson()));
  int uploads = 0;
  @override
  Future<WritingResponse> uploadWritingResponse({
    required String exerciseAttemptId,
    required String filePath,
    required String? payloadJson,
  }) async {
    uploads++;
    throw const ConflictException(
      'La evidencia está bloqueada.',
      code: 'ASSESSMENT_EVIDENCE_LOCKED',
    );
  }
}
