import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/network/api_client.dart';
import 'core/session/auth_session_manager.dart';
import 'core/session/authentication_status.dart';
import 'core/storage/auth_session_storage.dart';
import 'core/storage/secure_auth_session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/assessment/data/services/assessment_service.dart';
import 'features/assessment/data/services/mock_assessment_service.dart';
import 'features/assessment/presentation/pages/assessment_config_page.dart';
import 'features/assessment/presentation/pages/build_word_page.dart';
import 'features/assessment/presentation/pages/choose_word_page.dart';
import 'features/assessment/presentation/pages/reading_assessment_page.dart';
import 'features/assessment/presentation/pages/student_instructions_page.dart';
import 'features/assessment/presentation/pages/writing_assessment_page.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/classrooms/data/services/classroom_service.dart';
import 'features/classrooms/data/services/mock_classroom_service.dart';
import 'features/classrooms/presentation/pages/classroom_detail_page.dart';
import 'features/classrooms/presentation/pages/classrooms_page.dart';
import 'features/classrooms/presentation/pages/create_classroom_page.dart';
import 'features/classrooms/presentation/pages/edit_classroom_page.dart';
import 'features/exercises/data/services/exercise_service.dart';
import 'features/exercises/data/services/mock_exercise_service.dart';
import 'features/exercises/presentation/pages/exercise_catalog_page.dart';
import 'features/exercises/presentation/pages/exercise_detail_page.dart';
import 'features/students/data/services/mock_student_service.dart';
import 'features/students/data/services/student_service.dart';
import 'features/students/presentation/pages/create_student_page.dart';
import 'features/students/presentation/pages/edit_student_page.dart';
import 'features/students/presentation/pages/student_detail_page.dart';
import 'features/teacher/data/datasources/teacher_remote_data_source_impl.dart';
import 'features/teacher/data/repositories/teacher_repository_impl.dart';
import 'features/teacher/data/services/dashboard_summary_service.dart';
import 'features/teacher/data/services/mock_dashboard_summary_service.dart';
import 'features/teacher/domain/repositories/teacher_repository.dart';
import 'features/teacher/presentation/pages/teacher_home_page.dart';
import 'features/teacher/presentation/pages/teacher_profile_page.dart';

class TamiziaApp extends StatefulWidget {
  const TamiziaApp({this.sessionManager, super.key});

  final AuthSessionManager? sessionManager;

  @override
  State<TamiziaApp> createState() => _TamiziaAppState();
}

class _TamiziaAppState extends State<TamiziaApp> {
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final TeacherRepository _teacherRepository;
  late final AuthSessionStorage _sessionStorage;
  late final AuthSessionManager _sessionManager;

  final DashboardSummaryService _dashboardSummaryService =
      MockDashboardSummaryService();
  final ClassroomService _classroomService = MockClassroomService();
  final StudentService _studentService = MockStudentService();
  final ExerciseService _exerciseService = MockExerciseService();
  late final AssessmentService _assessmentService = MockAssessmentService(
    exerciseService: _exerciseService,
  );

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _teacherRepository = TeacherRepositoryImpl(
      remoteDataSource: TeacherRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _sessionStorage = SecureAuthSessionStorage();
    _sessionManager =
        widget.sessionManager ??
        AuthSessionManager(
          authRepository: _authRepository,
          teacherRepository: _teacherRepository,
          sessionStorage: _sessionStorage,
        );
    _apiClient.configureAuthentication(
      accessTokenProvider: _sessionManager.getValidAccessToken,
      refreshSession: _sessionManager.refreshSession,
    );
    _sessionManager.initialize();
  }

  @override
  void dispose() {
    if (widget.sessionManager == null) {
      _sessionManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamizIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        final page = _buildPage(settings);
        if (_isProtectedRoute(settings.name)) {
          return _ProtectedRoute(sessionManager: _sessionManager, child: page);
        }
        return page;
      },
    );
  }

  Widget _buildPage(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _InitialSessionGate(
          sessionManager: _sessionManager,
          dashboardSummaryService: _dashboardSummaryService,
        );
      case AppRoutes.login:
        return LoginPage(sessionManager: _sessionManager);
      case AppRoutes.register:
        return RegisterPage(sessionManager: _sessionManager);
      case AppRoutes.forgotPassword:
        return ForgotPasswordPage(authRepository: _authRepository);
      case AppRoutes.resetPassword:
        final arguments = settings.arguments;
        final token = arguments is String
            ? arguments
            : arguments is Map<String, dynamic>
            ? arguments['token'] as String? ?? ''
            : '';
        return ResetPasswordPage(authRepository: _authRepository, token: token);
      case AppRoutes.teacherHome:
        return TeacherHomePage(
          dashboardSummaryService: _dashboardSummaryService,
          sessionManager: _sessionManager,
        );
      case AppRoutes.teacherProfile:
        return TeacherProfilePage(sessionManager: _sessionManager);
      case AppRoutes.classrooms:
        return ClassroomsPage(classroomService: _classroomService);
      case AppRoutes.createClassroom:
        return CreateClassroomPage(classroomService: _classroomService);
      case AppRoutes.classroomDetail:
        return ClassroomDetailPage(
          classroomService: _classroomService,
          studentService: _studentService,
        );
      case AppRoutes.editClassroom:
        return EditClassroomPage(classroomService: _classroomService);
      case AppRoutes.createStudent:
        return CreateStudentPage(studentService: _studentService);
      case AppRoutes.studentDetail:
        return StudentDetailPage(studentService: _studentService);
      case AppRoutes.editStudent:
        return EditStudentPage(studentService: _studentService);
      case AppRoutes.exerciseCatalog:
        return ExerciseCatalogPage(exerciseService: _exerciseService);
      case AppRoutes.exerciseDetail:
        return ExerciseDetailPage(exerciseService: _exerciseService);
      case AppRoutes.assessmentConfigure:
        return AssessmentConfigPage(
          classroomService: _classroomService,
          studentService: _studentService,
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        );
      case AppRoutes.assessmentInstructions:
        return StudentInstructionsPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        );
      case AppRoutes.assessmentReading:
        return ReadingAssessmentPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        );
      case AppRoutes.assessmentWriting:
        return WritingAssessmentPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        );
      case AppRoutes.assessmentBuildWord:
        return BuildWordPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        );
      case AppRoutes.assessmentChooseWord:
        return ChooseWordPage(
          exerciseService: _exerciseService,
          assessmentService: _assessmentService,
        );
      default:
        return LoginPage(sessionManager: _sessionManager);
    }
  }

  bool _isProtectedRoute(String? route) {
    return route != AppRoutes.splash &&
        route != AppRoutes.login &&
        route != AppRoutes.register &&
        route != AppRoutes.forgotPassword &&
        route != AppRoutes.resetPassword;
  }
}

class _InitialSessionGate extends StatefulWidget {
  const _InitialSessionGate({
    required this.sessionManager,
    required this.dashboardSummaryService,
  });

  final AuthSessionManager sessionManager;
  final DashboardSummaryService dashboardSummaryService;

  @override
  State<_InitialSessionGate> createState() => _InitialSessionGateState();
}

class _InitialSessionGateState extends State<_InitialSessionGate> {
  bool _wasAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.sessionManager,
      builder: (context, _) {
        if (widget.sessionManager.status == AuthenticationStatus.unknown ||
            widget.sessionManager.status == AuthenticationStatus.refreshing) {
          return const _SessionLoadingPage();
        }
        if (widget.sessionManager.isAuthenticated) {
          _wasAuthenticated = true;
          return TeacherHomePage(
            dashboardSummaryService: widget.dashboardSummaryService,
            sessionManager: widget.sessionManager,
          );
        }
        if (_wasAuthenticated) {
          return LoginPage(sessionManager: widget.sessionManager);
        }
        return const SplashPage();
      },
    );
  }
}

class _ProtectedRoute extends StatelessWidget {
  const _ProtectedRoute({required this.sessionManager, required this.child});

  final AuthSessionManager sessionManager;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sessionManager,
      builder: (context, _) {
        if (sessionManager.status == AuthenticationStatus.unknown) {
          return const _SessionLoadingPage();
        }
        if (!sessionManager.isAuthenticated) {
          return LoginPage(sessionManager: sessionManager);
        }
        return child;
      },
    );
  }
}

class _SessionLoadingPage extends StatelessWidget {
  const _SessionLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
