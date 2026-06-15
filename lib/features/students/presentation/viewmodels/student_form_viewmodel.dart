import 'package:flutter/foundation.dart';

import '../../../../core/validators/auth_validators.dart';
import '../../data/services/student_service.dart';
import '../../domain/models/student.dart';

class StudentFormViewModel extends ChangeNotifier {
  StudentFormViewModel({required StudentService studentService})
    : _studentService = studentService;

  final StudentService _studentService;

  String id = '';
  String code = '';
  String age = '';
  String grade = '';
  String classroomId = '';
  String classroomName = '';
  bool hasParentAuthorization = false;
  bool isLoading = false;
  String? errorMessage;

  void setCode(String value) => code = value;
  void setAge(String value) => age = value;
  void setGrade(String value) {
    grade = value;
    notifyListeners();
  }

  void setClassroom(String value) {
    classroomName = value;
    classroomId = value;
    notifyListeners();
  }

  void setAuthorization(bool value) {
    hasParentAuthorization = value;
    notifyListeners();
  }

  Future<void> loadStudent(String studentId) async {
    isLoading = true;
    notifyListeners();
    final student = await _studentService.getStudentById(studentId);
    id = student.id;
    code = student.code;
    age = student.age.toString();
    grade = student.grade.replaceAll('Grado ', '');
    classroomId = student.classroomId;
    classroomName = student.classroomName;
    hasParentAuthorization = student.hasParentAuthorization;
    isLoading = false;
    notifyListeners();
  }

  bool validate() {
    errorMessage =
        AuthValidators.validateRequiredField(
          code,
          'El código o seudónimo es obligatorio.',
        ) ??
        AuthValidators.validateAge(age) ??
        AuthValidators.validateRequiredField(grade, 'Selecciona un grado.') ??
        AuthValidators.validateRequiredField(
          classroomName,
          'Selecciona un aula.',
        );
    notifyListeners();
    return errorMessage == null;
  }

  Future<bool> create() async {
    if (!validate()) return false;
    isLoading = true;
    notifyListeners();
    await _studentService.createStudent(_buildStudent('student-new'));
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> update() async {
    if (!validate()) return false;
    isLoading = true;
    notifyListeners();
    await _studentService.updateStudent(_buildStudent(id));
    isLoading = false;
    notifyListeners();
    return true;
  }

  Student _buildStudent(String studentId) {
    return Student(
      id: studentId,
      code: code.trim(),
      alias: code.trim(),
      age: int.tryParse(age) ?? 0,
      grade: grade,
      classroomId: classroomId.isEmpty ? classroomName : classroomId,
      classroomName: classroomName,
      lastEvaluation: 'N/A',
      consentStatus: hasParentAuthorization ? 'Aprobado' : 'Pendiente',
      revisionLevel: 'Sin evaluación',
      hasParentAuthorization: hasParentAuthorization,
    );
  }
}
