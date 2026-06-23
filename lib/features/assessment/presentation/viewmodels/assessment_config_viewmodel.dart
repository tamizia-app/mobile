import 'package:flutter/foundation.dart';

import '../../../../core/validators/auth_validators.dart';
import '../../../classrooms/data/services/classroom_service.dart';
import '../../../classrooms/domain/models/classroom.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../students/data/services/student_service.dart';
import '../../../students/domain/models/student.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';

class AssessmentConfigViewModel extends ChangeNotifier {
  AssessmentConfigViewModel({
    required ClassroomService classroomService,
    required StudentService studentService,
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _classroomService = classroomService,
       _studentService = studentService,
       _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ClassroomService _classroomService;
  final StudentService _studentService;
  final ExerciseService _exerciseService;
  final AssessmentService _assessmentService;

  List<Classroom> classrooms = const [];
  List<Student> students = const [];
  List<Exercise> exercises = const [];
  String classroomId = '';
  String studentId = '';
  String exerciseId = '';
  bool isLoading = false;
  String? errorMessage;
  AssessmentSession? session;

  Future<void> load({String? preselectedExerciseId}) async {
    isLoading = true;
    notifyListeners();
    classrooms = await _classroomService.getClassrooms();
    exercises = await _exerciseService.getExercises();
    if (preselectedExerciseId != null && preselectedExerciseId.isNotEmpty) {
      exerciseId = preselectedExerciseId;
    }
    if (classrooms.isNotEmpty) {
      students = await _studentService.getStudentsByClassroom(
        classrooms.first.id,
      );
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> setClassroom(String value) async {
    classroomId = value;
    studentId = '';
    students = await _studentService.getStudentsByClassroom(value);
    notifyListeners();
  }

  void setStudent(String value) {
    studentId = value;
    notifyListeners();
  }

  void setExercise(String value) {
    exerciseId = value;
    notifyListeners();
  }

  bool validate() {
    errorMessage =
        AuthValidators.validateRequiredField(
          classroomId,
          'Selecciona un aula.',
        ) ??
        AuthValidators.validateRequiredField(
          studentId,
          'Selecciona un estudiante.',
        ) ??
        AuthValidators.validateRequiredField(
          exerciseId,
          'Selecciona un ejercicio.',
        );
    notifyListeners();
    return errorMessage == null;
  }

  Future<AssessmentSession?> createSession() async {
    if (!validate()) return null;
    isLoading = true;
    notifyListeners();
    session = await _assessmentService.createSession(
      classroomId: classroomId,
      studentId: studentId,
      exerciseId: exerciseId,
    );
    isLoading = false;
    notifyListeners();
    return session;
  }
}
