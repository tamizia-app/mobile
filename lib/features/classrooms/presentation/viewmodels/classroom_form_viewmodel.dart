import 'package:flutter/foundation.dart';

import '../../../../core/validators/auth_validators.dart';
import '../../data/services/classroom_service.dart';
import '../../domain/models/classroom.dart';

class ClassroomFormViewModel extends ChangeNotifier {
  ClassroomFormViewModel({required ClassroomService classroomService})
    : _classroomService = classroomService;

  final ClassroomService _classroomService;

  String id = '';
  String name = '';
  String grade = '';
  String section = '';
  String schoolYear = '';
  bool isLoading = false;
  String? errorMessage;

  void setName(String value) => name = value;
  void setGrade(String value) {
    grade = value;
    notifyListeners();
  }

  void setSection(String value) {
    section = value;
    notifyListeners();
  }

  void setSchoolYear(String value) {
    schoolYear = value;
    notifyListeners();
  }

  Future<void> loadClassroom(String classroomId) async {
    isLoading = true;
    notifyListeners();
    final classroom = await _classroomService.getClassroomById(classroomId);
    id = classroom.id;
    name = classroom.name;
    grade = classroom.grade;
    section = classroom.section;
    schoolYear = classroom.schoolYear;
    isLoading = false;
    notifyListeners();
  }

  bool validate() {
    errorMessage =
        AuthValidators.validateRequiredField(
          name,
          'Este campo es obligatorio.',
        ) ??
        AuthValidators.validateRequiredField(grade, 'Selecciona un grado.') ??
        AuthValidators.validateRequiredField(
          section,
          'Selecciona una sección.',
        );
    notifyListeners();
    return errorMessage == null;
  }

  Future<bool> create() async {
    if (!validate()) return false;
    isLoading = true;
    notifyListeners();
    await _classroomService.createClassroom(
      Classroom(
        id: 'classroom-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        grade: grade,
        section: section,
        schoolYear: schoolYear.isEmpty ? '2026' : schoolYear,
        studentCount: 0,
      ),
    );
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> update() async {
    if (!validate()) return false;
    isLoading = true;
    notifyListeners();
    await _classroomService.updateClassroom(
      Classroom(
        id: id,
        name: name.trim(),
        grade: grade,
        section: section,
        schoolYear: schoolYear.isEmpty ? '2026' : schoolYear,
        studentCount: 24,
      ),
    );
    isLoading = false;
    notifyListeners();
    return true;
  }
}
