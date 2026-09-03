import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/student.dart';
import '../../domain/models/student_consent.dart';
import '../../domain/repositories/student_repository.dart';

class StudentDetailViewModel extends ChangeNotifier {
  StudentDetailViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  final StudentRepository _studentRepository;

  Student? student;
  StudentConsent? consent;
  bool isLoading = false;
  bool isDeleting = false;
  bool isUpdatingConsent = false;
  String? errorMessage;

  Future<void> loadStudent(String studentId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      student = await _studentRepository.getStudentById(studentId);
      consent = await _studentRepository.getConsent(studentId);
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyUpdate(Student updatedStudent) {
    student = updatedStudent;
    notifyListeners();
  }

  Future<bool> deleteStudent() async {
    final current = student;
    if (current == null || isDeleting) {
      return false;
    }
    isDeleting = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _studentRepository.deleteStudent(current.studentId);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> revokeConsent() async {
    final current = student;
    if (current == null || consent == null || isUpdatingConsent) {
      return false;
    }
    isUpdatingConsent = true;
    errorMessage = null;
    notifyListeners();
    try {
      consent = await _studentRepository.revokeConsent(current.studentId);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isUpdatingConsent = false;
      notifyListeners();
    }
  }

  Future<bool> uploadConsent({
    required List<int> bytes,
    required String fileName,
  }) async {
    final current = student;
    if (current == null || isUpdatingConsent) {
      return false;
    }
    isUpdatingConsent = true;
    errorMessage = null;
    notifyListeners();
    try {
      consent = await _studentRepository.uploadConsent(
        current.studentId,
        bytes: bytes,
        fileName: fileName,
      );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isUpdatingConsent = false;
      notifyListeners();
    }
  }
}
