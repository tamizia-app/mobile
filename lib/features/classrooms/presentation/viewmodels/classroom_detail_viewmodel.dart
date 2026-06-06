import 'package:flutter/foundation.dart';

import '../../../students/data/services/student_service.dart';
import '../../../students/domain/models/student.dart';
import '../../data/services/classroom_service.dart';
import '../../domain/models/classroom.dart';

class ClassroomDetailViewModel extends ChangeNotifier {
  ClassroomDetailViewModel({
    required ClassroomService classroomService,
    required StudentService studentService,
  }) : _classroomService = classroomService,
       _studentService = studentService;

  final ClassroomService _classroomService;
  final StudentService _studentService;

  Classroom? classroom;
  List<Student> students = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load(String classroomId) async {
    isLoading = true;
    notifyListeners();
    classroom = await _classroomService.getClassroomById(classroomId);
    students = await _studentService.getStudentsByClassroom(classroomId);
    isLoading = false;
    notifyListeners();
  }
}
