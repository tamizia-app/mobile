import 'package:flutter/foundation.dart';

import '../../data/services/student_service.dart';
import '../../domain/models/student.dart';

class StudentDetailViewModel extends ChangeNotifier {
  StudentDetailViewModel({required StudentService studentService})
    : _studentService = studentService;

  final StudentService _studentService;

  Student? student;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load(String studentId) async {
    isLoading = true;
    notifyListeners();
    student = await _studentService.getStudentById(studentId);
    isLoading = false;
    notifyListeners();
  }
}
