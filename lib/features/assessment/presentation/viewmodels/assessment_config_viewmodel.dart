import 'package:flutter/foundation.dart';

import '../../../../core/validators/auth_validators.dart';
import '../../../classrooms/domain/models/classroom.dart';
import '../../../classrooms/domain/repositories/classroom_repository.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../students/domain/models/student.dart';
import '../../../students/domain/repositories/student_repository.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';

class AssessmentConfigViewModel extends ChangeNotifier {
  AssessmentConfigViewModel({
    required ClassroomRepository classroomRepository,
    required StudentRepository studentRepository,
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _classroomRepository = classroomRepository,
       _studentRepository = studentRepository,
       _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ClassroomRepository _classroomRepository;
  final StudentRepository _studentRepository;
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
    classrooms = await _classroomRepository.getClassrooms();
    exercises = await _exerciseService.getExercises();
    if (preselectedExerciseId != null && preselectedExerciseId.isNotEmpty) {
      exerciseId = preselectedExerciseId;
    }
    if (classrooms.isNotEmpty) {
      students = await _studentRepository.getStudentsByClassroom(
        classrooms.first.id,
      );
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> setClassroom(String value) async {
    classroomId = value;
    studentId = '';
    students = await _studentRepository.getStudentsByClassroom(value);
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
