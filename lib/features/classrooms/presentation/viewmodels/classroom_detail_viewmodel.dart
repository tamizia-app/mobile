import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/classroom.dart';
import '../../domain/repositories/classroom_repository.dart';

class ClassroomDetailViewModel extends ChangeNotifier {
  ClassroomDetailViewModel({required ClassroomRepository classroomRepository})
    : _classroomRepository = classroomRepository;

  final ClassroomRepository _classroomRepository;

  Classroom? classroom;
  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;

  Future<void> loadClassroom(String classroomId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      classroom = await _classroomRepository.getClassroomById(classroomId);
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyUpdate(Classroom updatedClassroom) {
    classroom = updatedClassroom;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> deleteClassroom() async {
    final current = classroom;
    if (current == null || isDeleting) {
      return false;
    }
    isDeleting = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _classroomRepository.deleteClassroom(current.classroomId);
      return true;
    } on ConflictException {
      errorMessage =
          'No se puede eliminar el aula porque tiene información asociada.';
      return false;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
