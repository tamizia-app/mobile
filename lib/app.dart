import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/network/api_client.dart';
import 'core/session/auth_session_manager.dart';
import 'core/session/authentication_status.dart';
import 'core/storage/auth_session_storage.dart';
import 'core/storage/secure_auth_session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/assessment/data/datasources/assessment_remote_data_source_impl.dart';
import 'features/assessment/data/repositories/assessment_repository_impl.dart';
import 'features/assessment/domain/repositories/assessment_repository.dart';
import 'features/assessment/presentation/pages/assessment_result_page.dart';
import 'features/assessment/presentation/pages/assessment_config_page.dart';
import 'features/assessment/presentation/pages/assessment_attempt_preview_page.dart';
import 'features/assessment/presentation/pages/assessment_error_page.dart';
import 'features/assessment/presentation/pages/attempt_review_page.dart';
import 'features/assessment/presentation/pages/attempt_session_page.dart';
import 'features/assessment/presentation/pages/build_word_page.dart';
import 'features/assessment/presentation/pages/choose_word_page.dart';
import 'features/assessment/presentation/pages/reading_assessment_page.dart';
import 'features/assessment/presentation/pages/student_history_page.dart';
import 'features/assessment/presentation/pages/template_catalog_page.dart';
import 'features/assessment/presentation/pages/template_detail_page.dart';
import 'features/assessment/presentation/pages/text_comparison_page.dart';
import 'features/assessment/presentation/pages/writing_assessment_page.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/classrooms/data/datasources/classroom_remote_data_source_impl.dart';
import 'features/classrooms/data/repositories/classroom_repository_impl.dart';
import 'features/classrooms/domain/repositories/classroom_repository.dart';
import 'features/classrooms/presentation/pages/classroom_detail_page.dart';
import 'features/classrooms/presentation/pages/classrooms_page.dart';
import 'features/classrooms/presentation/pages/create_classroom_page.dart';
import 'features/classrooms/presentation/pages/edit_classroom_page.dart';
import 'features/exercises/data/services/exercise_service.dart';
import 'features/exercises/data/services/mock_exercise_service.dart';
import 'features/exercises/presentation/pages/exercise_catalog_page.dart';
import 'features/exercises/presentation/pages/exercise_detail_page.dart';
import 'features/students/data/datasources/student_remote_data_source_impl.dart';
import 'features/students/data/repositories/student_repository_impl.dart';
import 'features/students/domain/repositories/student_repository.dart';
import 'features/students/presentation/pages/create_student_page.dart';
import 'features/students/presentation/pages/edit_student_page.dart';
import 'features/students/presentation/pages/student_detail_page.dart';
import 'features/teacher/data/datasources/teacher_remote_data_source_impl.dart';
import 'features/teacher/data/repositories/teacher_repository_impl.dart';
import 'features/teacher/data/datasources/dashboard_remote_data_source_impl.dart';
import 'features/teacher/data/services/dashboard_summary_service.dart';
import 'features/teacher/data/services/dashboard_summary_service_impl.dart';
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
  late final ClassroomRepository _classroomRepository;
  late final StudentRepository _studentRepository;
  late final AssessmentRepository _assessmentRepository;
  late final AuthSessionStorage _sessionStorage;
  late final AuthSessionManager _sessionManager;

  late final DashboardSummaryService _dashboardSummaryService;
  final ExerciseService _exerciseService = MockExerciseService();

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _dashboardSummaryService = DashboardSummaryServiceImpl(
      remoteDataSource: DashboardRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _teacherRepository = TeacherRepositoryImpl(
      remoteDataSource: TeacherRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _classroomRepository = ClassroomRepositoryImpl(
      remoteDataSource: ClassroomRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _studentRepository = StudentRepositoryImpl(
      remoteDataSource: StudentRemoteDataSourceImpl(apiClient: _apiClient),
    );
    _assessmentRepository = AssessmentRepositoryImpl(
      remoteDataSource: AssessmentRemoteDataSourceImpl(apiClient: _apiClient),
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
        return ClassroomsPage(classroomRepository: _classroomRepository);
      case AppRoutes.createClassroom:
        return CreateClassroomPage(classroomRepository: _classroomRepository);
      case AppRoutes.classroomDetail:
        return ClassroomDetailPage(
          classroomRepository: _classroomRepository,
          studentRepository: _studentRepository,
        );
      case AppRoutes.editClassroom:
        return EditClassroomPage(classroomRepository: _classroomRepository);
      case AppRoutes.createStudent:
        return CreateStudentPage(studentRepository: _studentRepository);
      case AppRoutes.studentDetail:
        return StudentDetailPage(studentRepository: _studentRepository);
      case AppRoutes.editStudent:
        return EditStudentPage(studentRepository: _studentRepository);
      case AppRoutes.exerciseCatalog:
        return ExerciseCatalogPage(exerciseService: _exerciseService);
      case AppRoutes.exerciseDetail:
        return ExerciseDetailPage(exerciseService: _exerciseService);
      case AppRoutes.templateCatalog:
        return TemplateCatalogPage(assessmentRepository: _assessmentRepository);
      case AppRoutes.templateDetail:
        return TemplateDetailPage(assessmentRepository: _assessmentRepository);
      case AppRoutes.assessmentConfigure:
        return AssessmentConfigPage(
          classroomRepository: _classroomRepository,
          studentRepository: _studentRepository,
          assessmentRepository: _assessmentRepository,
        );
      case AppRoutes.assessmentAttemptPreview:
        return const AssessmentAttemptPreviewPage();
      case AppRoutes.assessmentAttemptSession:
        return AttemptSessionPage(assessmentRepository: _assessmentRepository);
      case AppRoutes.assessmentReading:
        return ReadingAssessmentPage(
          assessmentRepository: _assessmentRepository,
        );
      case AppRoutes.assessmentWriting:
        return WritingAssessmentPage(
          assessmentRepository: _assessmentRepository,
        );
      case AppRoutes.assessmentBuildWord:
        return BuildWordPage(assessmentRepository: _assessmentRepository);
      case AppRoutes.assessmentChooseWord:
        return ChooseWordPage(assessmentRepository: _assessmentRepository);
      case AppRoutes.assessmentResult:
        return const AssessmentResultPage();
      case AppRoutes.assessmentTextComparison:
        return const TextComparisonPage();
      case AppRoutes.assessmentError:
        return const AssessmentErrorPage();
      case AppRoutes.studentHistory:
        final studentId = settings.arguments as String?;
        if (studentId == null || studentId.isEmpty) {
          return const AssessmentErrorPage();
        }
        return StudentHistoryPage(
          assessmentRepository: _assessmentRepository,
          studentId: studentId,
        );
      case AppRoutes.attemptReview:
        final attemptId = settings.arguments as String?;
        if (attemptId == null || attemptId.isEmpty) {
          return const AssessmentErrorPage();
        }
        return AttemptReviewPage(
          assessmentRepository: _assessmentRepository,
          attemptId: attemptId,
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
