import 'package:tamizai_app/features/assessment/data/models/attempt_review_dto.dart';
import 'package:tamizai_app/features/assessment/data/models/manual_review_dto.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_review.dart';
import 'package:tamizai_app/features/assessment/domain/models/manual_review.dart';
import 'package:tamizai_app/features/assessment/domain/repositories/assessment_repository.dart';

Map<String, dynamic> exerciseJson({
  String type = 'READING_WRITING',
  int? version = 0,
}) => {
  'exercise_attempt_id': 'ea-1',
  'exercise_id': 'ex-1',
  'order_index': 1,
  'type': type,
  'title': 'Revisa la lectura',
  'status': 'EVALUATED',
  'instructions': 'Lee el texto indicado.',
  'reference_text': 'Mi casa es azul.',
  'technical_status': 'PARTIAL',
  'score_eligible': true,
  'score': 63.5,
  'original_score': null,
  'current_score': 63.5,
  'review_required': true,
  'review_version': version,
  'review_status': 'pending',
  'manual_adjustment_applied': false,
  'response': {
    'recognized_text': 'Mi casa azul.',
    'free_transcription_text': 'Mi casa azul.',
    'assessment_recognized_text': 'Mi casa es azul',
    'reviewed_recognized_text': null,
    'reviewed_free_transcription_text': null,
  },
  'metrics': {
    'original_metrics': {
      'accuracy_score': 70,
      'fluency_score': null,
      'char_accuracy': 0,
    },
    'current_metrics': {
      'accuracy_score': 70,
      'fluency_score': null,
      'char_accuracy': 0,
    },
  },
  'metric_sources': null,
  'manual_review_history': <Map<String, dynamic>>[],
};

AttemptReview reviewFrom(
  Map<String, dynamic> exercise, {
  String status = 'COMPLETED',
  double score = 63.5,
}) => AttemptReviewDto.fromJson({
  'attempt_id': 'attempt-1',
  'status': status,
  'result': {
    'attempt_id': 'attempt-1',
    'final_score': score,
    'intervention_level': 'MEDIUM',
  },
  'exercise_reviews': [exercise],
}).toDomain();

Map<String, dynamic> responseJson(int version) => {
  'exercise_attempt_id': 'ea-1',
  'exercise_type': 'READING_SPEAKING',
  'review_version': version,
  'review_status': 'overridden',
  'score_eligible': true,
  'manual_review_required': false,
  'manual_adjustment_applied': true,
  'original_score': null,
  'current_score': 82.25,
  'original_metrics': {'fluency_score': null},
  'current_metrics': {'fluency_score': 0},
  'assessment_result': {
    'original_final_score': null,
    'current_final_score': 76.75,
  },
};

class ReviewRepositoryFake implements AssessmentRepository {
  ReviewRepositoryFake(this.current);
  AttemptReview current;
  int reads = 0;
  final requests = <ManualReviewRequest>[];
  Future<AttemptReview> Function()? onRead;
  Future<ManualReviewResponse> Function(ManualReviewRequest)? onPatch;

  @override
  Future<AttemptReview> getAttemptReview(String attemptId) async {
    reads++;
    return onRead == null ? current : await onRead!();
  }

  @override
  Future<ManualReviewResponse> manualReviewExercise(
    String id,
    ManualReviewRequest request,
  ) async {
    requests.add(request);
    return onPatch == null
        ? ManualReviewResponseDto.fromJson(responseJson(7)).toDomain()
        : await onPatch!(request);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
