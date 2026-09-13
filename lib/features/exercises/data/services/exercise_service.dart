import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_category.dart';

abstract class ExerciseService {
  Future<List<Exercise>> getExercises();

  Future<Exercise> getExerciseById(String id);

  Future<List<ExerciseCategory>> getCategories();
}
