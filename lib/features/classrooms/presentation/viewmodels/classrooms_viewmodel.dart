import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/classroom.dart';
import '../../domain/repositories/classroom_repository.dart';

class ClassroomsViewModel extends ChangeNotifier {
  ClassroomsViewModel({required ClassroomRepository classroomRepository})
    : _classroomRepository = classroomRepository;

  final ClassroomRepository _classroomRepository;

  List<Classroom> classrooms = const [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;
  String searchQuery = '';

  List<Classroom> get filteredClassrooms {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return classrooms;
    }
    return classrooms
        .where((classroom) {
          return classroom.name.toLowerCase().contains(query) ||
              classroom.gradeLevel.toLowerCase().contains(query) ||
              classroom.section.toLowerCase().contains(query) ||
              classroom.schoolYear.year.toString().contains(query);
        })
        .toList(growable: false);
  }

  Future<void> loadClassrooms() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await _fetchClassrooms();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshClassrooms() async {
    if (isRefreshing) {
      return;
    }
    isRefreshing = true;
    notifyListeners();
    await _fetchClassrooms();
    isRefreshing = false;
    notifyListeners();
  }

  Future<void> _fetchClassrooms() async {
    try {
      classrooms = await _classroomRepository.getClassrooms();
      errorMessage = null;
    } on ApiException catch (error) {
      errorMessage = error.message;
    }
  }

  void search(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    if (searchQuery.isEmpty) {
      return;
    }
    searchQuery = '';
    notifyListeners();
  }

  void addClassroom(Classroom classroom) {
    classrooms = [classroom, ...classrooms];
    notifyListeners();
  }

  void updateClassroomInList(Classroom classroom) {
    classrooms = classrooms
        .map(
          (item) =>
              item.classroomId == classroom.classroomId ? classroom : item,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void removeClassroom(String classroomId) {
    classrooms = classrooms
        .where((item) => item.classroomId != classroomId)
        .toList(growable: false);
    notifyListeners();
  }
}
