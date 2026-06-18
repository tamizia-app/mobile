import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/assessment/data/services/assessment_service.dart';
import 'features/assessment/data/services/mock_assessment_service.dart';
import 'features/assessment/presentation/pages/assessment_config_page.dart';
import 'features/assessment/presentation/pages/build_word_page.dart';
import 'features/assessment/presentation/pages/choose_word_page.dart';
import 'features/assessment/presentation/pages/reading_assessment_page.dart';
import 'features/assessment/presentation/pages/student_instructions_page.dart';
import 'features/assessment/presentation/pages/writing_assessment_page.dart';
import 'features/classrooms/data/services/classroom_service.dart';
import 'features/classrooms/data/services/mock_classroom_service.dart';
import 'features/classrooms/presentation/pages/classroom_detail_page.dart';
import 'features/classrooms/presentation/pages/classrooms_page.dart';
import 'features/classrooms/presentation/pages/create_classroom_page.dart';
import 'features/classrooms/presentation/pages/edit_classroom_page.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/data/services/mock_auth_service.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/exercises/data/services/exercise_service.dart';
import 'features/exercises/data/services/mock_exercise_service.dart';
import 'features/exercises/presentation/pages/exercise_catalog_page.dart';
import 'features/exercises/presentation/pages/exercise_detail_page.dart';
import 'features/students/data/services/mock_student_service.dart';
import 'features/students/data/services/student_service.dart';
import 'features/students/presentation/pages/create_student_page.dart';
import 'features/students/presentation/pages/edit_student_page.dart';
import 'features/students/presentation/pages/student_detail_page.dart';
import 'features/teacher/data/services/mock_teacher_service.dart';
import 'features/teacher/data/services/teacher_service.dart';
import 'features/teacher/presentation/pages/teacher_home_page.dart';
import 'features/teacher/presentation/pages/teacher_profile_page.dart';

class TamiziaApp extends StatelessWidget {
  const TamiziaApp({super.key});

  static final AuthService _authService = MockAuthService();
  static final TeacherService _teacherService = MockTeacherService();
  static final ClassroomService _classroomService = MockClassroomService();
  static final StudentService _studentService = MockStudentService();
  static final ExerciseService _exerciseService = MockExerciseService();
  static final AssessmentService _assessmentService = MockAssessmentService(
    exerciseService: _exerciseService,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamizIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => LoginPage(authService: _authService),
        AppRoutes.register: (_) => RegisterPage(authService: _authService),
        AppRoutes.forgotPassword: (_) =>
            ForgotPasswordPage(authService: _authService),
        AppRoutes.teacherHome: (_) =>
            TeacherHomePage(teacherService: _teacherService),
        AppRoutes.teacherProfile: (_) =>
            TeacherProfilePage(teacherService: _teacherService),
        AppRoutes.classrooms: (_) =>
            ClassroomsPage(classroomService: _classroomService),
        AppRoutes.createClassroom: (_) =>
            CreateClassroomPage(classroomService: _classroomService),
        AppRoutes.classroomDetail: (_) => ClassroomDetailPage(
          classroomService: _classroomService,
          studentService: _studentService,
        ),
        AppRoutes.editClassroom: (_) =>
            EditClassroomPage(classroomService: _classroomService),
        AppRoutes.createStudent: (_) =>
            CreateStudentPage(studentService: _studentService),
        AppRoutes.studentDetail: (_) =>
            StudentDetailPage(studentService: _studentService),
        AppRoutes.editStudent: (_) =>
            EditStudentPage(studentService: _studentService),
        AppRoutes.exerciseCatalog: (_) =>
            ExerciseCatalogPage(exerciseService: _exerciseService),
        AppRoutes.exerciseDetail: (_) =>
            ExerciseDetailPage(exerciseService: _exerciseService),
        AppRoutes.assessmentConfigure: (_) => AssessmentConfigPage(
          classroomService: _classroomService,
          studentService: _studentService,
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        ),
        AppRoutes.assessmentInstructions: (_) => StudentInstructionsPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        ),
        AppRoutes.assessmentReading: (_) => ReadingAssessmentPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        ),
        AppRoutes.assessmentWriting: (_) => WritingAssessmentPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        ),
        AppRoutes.assessmentBuildWord: (_) => BuildWordPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        ),
        AppRoutes.assessmentChooseWord: (_) => ChooseWordPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        ),
      },
    );
  }
}
