import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/classroom.dart';
import '../../domain/models/create_classroom_request.dart';
import '../../domain/models/update_classroom_request.dart';
import '../../domain/repositories/classroom_repository.dart';

class ClassroomFormViewModel extends ChangeNotifier {
  ClassroomFormViewModel({required ClassroomRepository classroomRepository})
    : _classroomRepository = classroomRepository;

  static const gradeLevels = <String>[
    'primero',
    'segundo',
    'tercero',
    'cuarto',
    'quinto',
    'sexto',
  ];
  static const sections = <String>[
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  final ClassroomRepository _classroomRepository;

  Classroom? _originalClassroom;
  String? _editingClassroomId;
  String name = '';
  String gradeLevel = '';
  String section = '';
  DateTime? schoolYear;
  bool isLoading = false;
  String? generalError;
  Map<String, String> fieldErrors = const {};

  bool get isEditing => _editingClassroomId != null;
  bool get isInitialized => !isEditing || _originalClassroom != null;
  List<int> get availableSchoolYears {
    final currentYear = DateTime.now().year;
    return List<int>.generate(4, (index) => currentYear - 1 + index);
  }

  bool get isFormValid {
    return name.trim().isNotEmpty &&
        gradeLevels.contains(gradeLevel) &&
        sections.contains(section.trim().toUpperCase()) &&
        schoolYear != null &&
        availableSchoolYears.contains(schoolYear!.year);
  }

  bool get hasChanges {
    final original = _originalClassroom;
    if (original == null) {
      return isFormValid;
    }
    return name.trim() != original.name.trim() ||
        gradeLevel != original.gradeLevel ||
        section.trim().toUpperCase() != original.section ||
        schoolYear?.year != original.schoolYear.year;
  }

  bool get canSave => isFormValid && hasChanges && !isLoading;

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setGradeLevel(String value) {
    gradeLevel = value;
    notifyListeners();
  }

  void setSection(String value) {
    section = value.trim().toUpperCase();
    notifyListeners();
  }

  void setSchoolYear(int year) {
    schoolYear = DateTime(year);
    notifyListeners();
  }

  Future<void> loadClassroom(String classroomId) async {
    if (isLoading || _originalClassroom?.classroomId == classroomId) {
      return;
    }
    _editingClassroomId = classroomId;
    isLoading = true;
    generalError = null;
    notifyListeners();
    try {
      final classroom = await _classroomRepository.getClassroomById(
        classroomId,
      );
      _originalClassroom = classroom;
      _applyClassroom(classroom);
    } on ApiException catch (error) {
      generalError = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void restore() {
    final original = _originalClassroom;
    if (original == null) {
      return;
    }
    _applyClassroom(original);
    generalError = null;
    fieldErrors = const {};
    notifyListeners();
  }

  Future<Classroom?> create() async {
    if (!canSave) {
      return null;
    }
    return _submit(
      () => _classroomRepository.createClassroom(
        CreateClassroomRequest(
          name: name.trim(),
          gradeLevel: gradeLevel,
          section: section.trim().toUpperCase(),
          schoolYear: DateTime(schoolYear!.year),
        ),
      ),
    );
  }

  Future<Classroom?> update() async {
    final original = _originalClassroom;
    if (original == null || !canSave) {
      return null;
    }
    final updated = await _submit(
      () => _classroomRepository.updateClassroom(
        original.classroomId,
        UpdateClassroomRequest(
          name: name.trim(),
          gradeLevel: gradeLevel,
          section: section.trim().toUpperCase(),
          schoolYear: DateTime(schoolYear!.year),
        ),
      ),
    );
    if (updated != null) {
      _originalClassroom = updated;
      _applyClassroom(updated);
      notifyListeners();
    }
    return updated;
  }

  Future<Classroom?> _submit(Future<Classroom> Function() operation) async {
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

  void _applyClassroom(Classroom classroom) {
    name = classroom.name;
    gradeLevel = classroom.gradeLevel;
    section = classroom.section;
    schoolYear = DateTime(classroom.schoolYear.year);
    fieldErrors = const {};
  }
}
