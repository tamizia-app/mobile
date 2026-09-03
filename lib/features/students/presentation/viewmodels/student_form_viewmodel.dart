import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/create_student_request.dart';
import '../../domain/models/student.dart';
import '../../domain/models/update_student_request.dart';
import '../../domain/repositories/student_repository.dart';

enum StudentConsentUploadStatus { notSelected, uploaded, pending }

class SelectedConsentFile {
  const SelectedConsentFile({required this.name, required this.bytes});

  final String name;
  final List<int> bytes;

  int get size => bytes.length;
}

class StudentCreationResult {
  const StudentCreationResult({
    required this.student,
    required this.consentStatus,
  });

  final Student student;
  final StudentConsentUploadStatus consentStatus;

  String get message {
    return switch (consentStatus) {
      StudentConsentUploadStatus.notSelected =>
        'Estudiante registrado correctamente.',
      StudentConsentUploadStatus.uploaded =>
        'Estudiante registrado correctamente con consentimiento adjunto.',
      StudentConsentUploadStatus.pending =>
        'El estudiante fue registrado, pero no se pudo subir el '
            'consentimiento. Puedes intentarlo nuevamente desde el detalle '
            'del estudiante.',
    };
  }
}

class StudentFormViewModel extends ChangeNotifier {
  StudentFormViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  static const genders = <String>['BOY', 'GIRL'];

  final StudentRepository _studentRepository;

  Student? _originalStudent;
  String? _editingStudentId;
  String classroomId = '';
  String code = '';
  String age = '';
  String gender = '';
  bool isLoading = false;
  bool isSubmitting = false;
  bool isUploadingConsent = false;
  SelectedConsentFile? selectedConsentFile;
  String? generalError;
  Map<String, String> fieldErrors = const {};

  bool get isEditing => _editingStudentId != null;
  bool get isInitialized => !isEditing || _originalStudent != null;
  bool get isFormValid {
    final parsedAge = int.tryParse(age.trim());
    return code.trim().isNotEmpty &&
        code.trim().length <= 50 &&
        parsedAge != null &&
        parsedAge >= 4 &&
        parsedAge <= 18 &&
        genders.contains(gender);
  }

  bool get hasChanges {
    final original = _originalStudent;
    if (original == null) {
      return isFormValid;
    }
    return code.trim() != original.code.trim() ||
        int.tryParse(age.trim()) != original.age ||
        gender != original.gender;
  }

  bool get canSave =>
      isFormValid &&
      hasChanges &&
      !isLoading &&
      !isSubmitting &&
      !isUploadingConsent;

  void initializeForCreate(String classroomId) {
    this.classroomId = classroomId;
    generalError = null;
    fieldErrors = const {};
    notifyListeners();
  }

  void setCode(String value) {
    code = value;
    notifyListeners();
  }

  void setAge(String value) {
    age = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  bool selectConsentFile({required String name, required List<int> bytes}) {
    final extension = name.split('.').last.toLowerCase();
    const allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};
    if (bytes.isEmpty || !allowedExtensions.contains(extension)) {
      generalError = 'Selecciona un archivo PDF, JPG, JPEG o PNG válido.';
      notifyListeners();
      return false;
    }
    selectedConsentFile = SelectedConsentFile(name: name, bytes: bytes);
    generalError = null;
    notifyListeners();
    return true;
  }

  void removeConsentFile() {
    selectedConsentFile = null;
    notifyListeners();
  }

  Future<void> loadStudent(String studentId) async {
    if (isLoading || _originalStudent?.studentId == studentId) {
      return;
    }
    _editingStudentId = studentId;
    isLoading = true;
    generalError = null;
    notifyListeners();
    try {
      initializeForEdit(await _studentRepository.getStudentById(studentId));
    } on ApiException catch (error) {
      generalError = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeForEdit(Student student) {
    _originalStudent = student;
    classroomId = student.classroomId;
    _applyStudent(student);
    generalError = null;
    fieldErrors = const {};
    notifyListeners();
  }

  void resetForm() {
    final original = _originalStudent;
    if (original == null) {
      return;
    }
    _applyStudent(original);
    generalError = null;
    fieldErrors = const {};
    notifyListeners();
  }

  Future<Student?> createStudent() async {
    return (await createStudentWithOptionalConsent())?.student;
  }

  Future<StudentCreationResult?> createStudentWithOptionalConsent() async {
    if (classroomId.isEmpty || !canSave) {
      return null;
    }
    isSubmitting = true;
    generalError = null;
    fieldErrors = const {};
    notifyListeners();
    try {
      final student = await _studentRepository.createStudent(
        classroomId,
        CreateStudentRequest(
          code: code.trim(),
          age: int.parse(age.trim()),
          gender: gender,
        ),
      );
      final file = selectedConsentFile;
      if (file == null) {
        return StudentCreationResult(
          student: student,
          consentStatus: StudentConsentUploadStatus.notSelected,
        );
      }

      isUploadingConsent = true;
      notifyListeners();
      try {
        await _studentRepository.uploadConsent(
          student.studentId,
          bytes: file.bytes,
          fileName: file.name,
        );
        return StudentCreationResult(
          student: student,
          consentStatus: StudentConsentUploadStatus.uploaded,
        );
      } on ApiException {
        return StudentCreationResult(
          student: student,
          consentStatus: StudentConsentUploadStatus.pending,
        );
      } finally {
        isUploadingConsent = false;
      }
    } on ApiException catch (error) {
      generalError = error.message;
      fieldErrors = error.fieldErrors;
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Student?> updateStudent() async {
    final original = _originalStudent;
    if (original == null || !canSave) {
      return null;
    }
    final updated = await _submit(
      () => _studentRepository.updateStudent(
        original.studentId,
        UpdateStudentRequest(
          code: code.trim(),
          age: int.parse(age.trim()),
          gender: gender,
        ),
      ),
    );
    if (updated != null) {
      _originalStudent = updated;
      _applyStudent(updated);
      notifyListeners();
    }
    return updated;
  }

  Future<Student?> _submit(Future<Student> Function() operation) async {
    isLoading = true;
    generalError = null;
    fieldErrors = const {};
    notifyListeners();
    try {
      return await operation();
    } on ApiException catch (error) {
      generalError = error.message;
      fieldErrors = error.fieldErrors;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyStudent(Student student) {
    code = student.code;
    age = student.age.toString();
    gender = student.gender;
  }
}
