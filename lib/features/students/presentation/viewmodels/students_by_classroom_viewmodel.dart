import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/student.dart';
import '../../domain/repositories/student_repository.dart';

class StudentsByClassroomViewModel extends ChangeNotifier {
  StudentsByClassroomViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  final StudentRepository _studentRepository;

  List<Student> students = const [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;
  String searchQuery = '';
  String classroomId = '';

  List<Student> get filteredStudents {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return students;
    }
    return students
        .where((student) => student.code.toLowerCase().contains(query))
        .toList(growable: false);
  }

  Future<void> loadStudents(String classroomId) async {
    this.classroomId = classroomId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await _fetch();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshStudents() async {
    if (classroomId.isEmpty || isRefreshing) {
      return;
    }
    isRefreshing = true;
    notifyListeners();
    await _fetch();
    isRefreshing = false;
    notifyListeners();
  }

  Future<void> _fetch() async {
    try {
      students = await _studentRepository.getStudentsByClassroom(classroomId);
      errorMessage = null;
    } on ApiException catch (error) {
      errorMessage = error.message;
    }
  }

  void search(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void addStudent(Student student) {
    students = [student, ...students];
    notifyListeners();
  }

  void updateStudentInList(Student student) {
    students = students
        .map((item) => item.studentId == student.studentId ? student : item)
        .toList(growable: false);
    notifyListeners();
  }

  void removeStudent(String studentId) {
    students = students
        .where((item) => item.studentId != studentId)
        .toList(growable: false);
    notifyListeners();
  }
}
