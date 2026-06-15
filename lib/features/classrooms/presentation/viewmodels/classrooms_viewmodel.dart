import 'package:flutter/foundation.dart';

import '../../data/services/classroom_service.dart';
import '../../domain/models/classroom.dart';

class ClassroomsViewModel extends ChangeNotifier {
  ClassroomsViewModel({required ClassroomService classroomService})
    : _classroomService = classroomService;

  final ClassroomService _classroomService;

  List<Classroom> classrooms = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    classrooms = await _classroomService.getClassrooms();
    isLoading = false;
    notifyListeners();
  }
}
