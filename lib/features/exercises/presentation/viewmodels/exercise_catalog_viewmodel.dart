import 'package:flutter/foundation.dart';

import '../../data/services/exercise_service.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_category.dart';

class ExerciseCatalogViewModel extends ChangeNotifier {
  ExerciseCatalogViewModel({required ExerciseService exerciseService})
    : _exerciseService = exerciseService;

  final ExerciseService _exerciseService;

  List<Exercise> exercises = const [];
  List<ExerciseCategory> categories = const [];
  String selectedCategory = 'Lectura';
  String searchQuery = '';
  bool isSearching = false;
  bool isLoading = false;
  String? errorMessage;

  List<Exercise> get filteredExercises {
    final query = searchQuery.trim().toLowerCase();
    return exercises
        .where((exercise) => exercise.category == selectedCategory)
        .where((exercise) {
          if (query.isEmpty) return true;
          return exercise.title.toLowerCase().contains(query) ||
              exercise.description.toLowerCase().contains(query) ||
              exercise.category.toLowerCase().contains(query) ||
              exercise.typeLabel.toLowerCase().contains(query);
        })
        .toList();
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    categories = await _exerciseService.getCategories();
    exercises = await _exerciseService.getExercises();
    isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchQuery = '';
    }
    notifyListeners();
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
