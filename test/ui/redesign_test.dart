import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/theme/app_theme.dart';
import 'package:tamizai_app/core/theme/app_colors.dart';
import 'package:tamizai_app/core/session/auth_session_manager.dart';
import 'package:tamizai_app/core/session/authentication_status.dart';
import 'package:tamizai_app/core/storage/auth_session_storage.dart';
import 'package:tamizai_app/core/widgets/primary_button.dart';
import 'package:tamizai_app/core/widgets/app_states.dart';
import 'package:tamizai_app/core/widgets/assessment_result_summary.dart';
import 'package:tamizai_app/core/constants/app_routes.dart';
import 'package:tamizai_app/core/widgets/selectable_word_card.dart';
import 'package:tamizai_app/core/widgets/drawing_canvas_placeholder.dart';
import 'package:tamizai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamizai_app/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:tamizai_app/features/teacher/domain/models/teacher_profile.dart';
import 'package:tamizai_app/features/teacher/domain/models/dashboard_summary.dart';
import 'package:tamizai_app/features/teacher/data/services/dashboard_summary_service.dart';
import 'package:tamizai_app/features/classrooms/domain/repositories/classroom_repository.dart';
import 'package:tamizai_app/features/classrooms/domain/models/classroom.dart';
import 'package:tamizai_app/features/students/domain/repositories/student_repository.dart';
import 'package:tamizai_app/features/students/domain/models/student.dart';
import 'package:tamizai_app/features/students/domain/models/student_consent.dart';
import 'package:tamizai_app/features/assessment/domain/repositories/assessment_repository.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_template.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_attempt.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_result.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_response.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_exercise_args.dart';
import 'package:tamizai_app/features/assessment/domain/models/attempt_review.dart';
import 'package:tamizai_app/features/assessment/domain/models/exercise_integrity.dart';
import 'package:tamizai_app/features/assessment/domain/models/student_assessment_history.dart';
import 'package:tamizai_app/features/exercises/data/services/mock_exercise_service.dart';
import 'package:tamizai_app/features/auth/presentation/pages/splash_page.dart';
import 'package:tamizai_app/features/auth/presentation/pages/login_page.dart';
import 'package:tamizai_app/features/auth/presentation/pages/register_page.dart';
import 'package:tamizai_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tamizai_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:tamizai_app/features/teacher/presentation/pages/teacher_home_page.dart';
import 'package:tamizai_app/features/teacher/presentation/pages/teacher_profile_page.dart';
import 'package:tamizai_app/features/classrooms/presentation/pages/classrooms_page.dart';
import 'package:tamizai_app/features/classrooms/presentation/pages/classroom_detail_page.dart';
import 'package:tamizai_app/features/classrooms/presentation/pages/create_classroom_page.dart';
import 'package:tamizai_app/features/classrooms/presentation/pages/edit_classroom_page.dart';
import 'package:tamizai_app/features/students/presentation/pages/students_list_page.dart';
import 'package:tamizai_app/features/students/presentation/pages/student_detail_page.dart';
import 'package:tamizai_app/features/students/presentation/pages/create_student_page.dart';
import 'package:tamizai_app/features/students/presentation/pages/edit_student_page.dart';
import 'package:tamizai_app/features/exercises/presentation/pages/exercise_catalog_page.dart';
import 'package:tamizai_app/features/exercises/presentation/pages/exercise_detail_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/template_catalog_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/template_detail_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_config_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_result_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/reading_assessment_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/writing_assessment_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/choose_word_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/build_word_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/attempt_review_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/student_history_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_error_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/text_comparison_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/assessment_attempt_preview_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/attempt_session_page.dart';
import 'package:tamizai_app/features/assessment/presentation/pages/student_instructions_page.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_attempt_preview.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_session.dart';
import 'package:tamizai_app/features/assessment/domain/models/assessment_type.dart';
import 'package:tamizai_app/features/assessment/data/services/assessment_service.dart';

final _classroom = Classroom(
  classroomId: 'c',
  homeroomTeacherId: 't',
  name: 'Exploradores',
  gradeLevel: 'tercero',
  section: 'A',
  schoolYear: DateTime(2026),
);
final _student = Student(
  studentId: 's',
  classroomId: 'c',
  code: 'EST-003',
  age: 8,
  gender: 'GIRL',
  isActive: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
const _teacher = TeacherProfile(
  teacherId: 't',
  name: 'Lucía',
  lastname: 'Paredes',
  email: 'docente@example.test',
  instituteName: 'Escuela de primaria',
  phone: '987654321',
);
const _template = AssessmentTemplate(
  templateId: 'p',
  name: 'Lectura y escritura · Tercer grado',
  description:
      'Actividades de lectura, escritura y reconocimiento de palabras.',
  version: 1,
  isActive: true,
);
const _result = AssessmentResult(
  attemptId: 'a',
  finalScore: 72.5,
  interventionLevel: 'MEDIUM',
  totalExercises: 4,
  evaluatedExercises: 4,
  mcCorrectCount: 1,
  osCorrectCount: 1,
);

class _Auth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Storage implements AuthSessionStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Teacher implements TeacherRepository {
  @override
  Future<TeacherProfile> getMyProfile() async => _teacher;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthSessionManager _session() =>
    AuthSessionManager(
        authRepository: _Auth(),
        teacherRepository: _Teacher(),
        sessionStorage: _Storage(),
      )
      ..currentTeacher = _teacher
      ..status = AuthenticationStatus.authenticated;

class _Dashboard implements DashboardSummaryService {
  @override
  Future<DashboardSummary> getDashboardSummary() async =>
      const DashboardSummary(
        totalStudents: 24,
        totalClassrooms: 2,
        totalTemplates: 3,
        totalAssessments: 12,
        completedAttempts: 9,
        inProgressAttempts: 3,
      );
}

class _Classrooms implements ClassroomRepository {
  @override
  Future<List<Classroom>> getClassrooms() async => [_classroom];
  @override
  Future<Classroom> getClassroomById(String id) async => _classroom;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Students implements StudentRepository {
  @override
  Future<List<Student>> getAllStudents() async => [_student];
  @override
  Future<List<Student>> getStudentsByClassroom(String id) async => [_student];
  @override
  Future<Student> getStudentById(String id) async => _student;
  @override
  Future<StudentConsent?> getConsent(String id) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Assessments implements AssessmentRepository {
  @override
  Future<AssessmentAttempt> getAttemptById(String id) async => _attempt();
  @override
  Future<List<AssessmentTemplate>> getTemplates() async => [_template];
  @override
  Future<AssessmentTemplate> getTemplateById(String id) async => _template;
  @override
  Future<MCResponse?> getMCResponse(String id) async => null;
  @override
  Future<OSResponse?> getOSResponse(String id) async => null;
  @override
  Future<SpeakingResponse?> getSpeakingResponse(String id) async => null;
  @override
  Future<WritingResponse?> getWritingResponse(String id) async => null;
  @override
  Future<AttemptReview> getAttemptReview(String id) async =>
      const AttemptReview(
        attemptId: 'a',
        status: 'COMPLETED',
        student: AttemptReviewStudent(
          studentId: 's',
          code: 'EST-003',
          age: 8,
          gender: 'GIRL',
        ),
        assessment: AttemptReviewAssessment(
          assessmentId: 'v',
          title: 'Lectura y escritura · Tercer grado',
        ),
        result: AttemptReviewResult(
          attemptId: 'a',
          finalScore: 72.5,
          interventionLevel: 'MEDIUM',
        ),
        exerciseReviews: [
          ExerciseReview(
            exerciseAttemptId: 'e',
            exerciseId: 'e',
            orderIndex: 1,
            type: 'READING_SPEAKING',
            title: 'Lee en voz alta',
            status: 'EVALUATED',
            score: 72.5,
            referenceText: 'El sol brilla en el cielo.',
            technicalStatus: TechnicalStatus.valid,
            scoreEligible: true,
            scoringComponents: ScoringComponents(
              pronunciationScore: 72.5,
              accuracyScore: 80.2,
              fluencyScore: 68.4,
              completenessScore: 95,
              lexicalMatch: 83.3,
            ),
            response: {'recognized_text': 'El sol brilla en cielo.'},
          ),
          ExerciseReview(
            exerciseAttemptId: 'w',
            exerciseId: 'w',
            orderIndex: 2,
            type: 'READING_WRITING',
            title: 'Escribe la oración',
            status: 'EVALUATED',
            score: 86.3,
            referenceText: 'El sol brilla en el cielo.',
            technicalStatus: TechnicalStatus.partial,
            scoreEligible: false,
            reviewRequired: true,
            reviewReasons: ['LOW_OCR_CONFIDENCE'],
            scoringComponents: ScoringComponents(
              similarityScore: 86.3,
              confidenceAvg: 0.748,
              cer: 0.071,
              wer: 0.333,
            ),
            response: {'recognized_text': 'El sol brila en el cielo.'},
          ),
        ],
      );
  @override
  Future<StudentAssessmentHistory> getStudentHistory(
    String id, {
    int? limit,
    int? offset,
    String? status,
    String? assessmentId,
    String? dateFrom,
    String? dateTo,
  }) async => StudentAssessmentHistory(
    studentId: 's',
    student: const StudentBrief(
      studentId: 's',
      code: 'EST-003',
      age: 8,
      gender: 'GIRL',
    ),
    summary: const StudentHistorySummary(
      attemptsCount: 1,
      completedAttemptsCount: 1,
    ),
    items: [
      StudentHistoryItem(
        attemptId: 'a',
        assessmentId: 'v',
        status: 'COMPLETED',
        assessmentName: 'Lectura y escritura',
        finalScore: 72.5,
        interventionLevel: 'MEDIUM',
        completedAt: DateTime(2026, 9, 10),
      ),
    ],
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LegacyAssessment implements AssessmentService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AssessmentAttempt _attempt() => AssessmentAttempt(
  attemptId: 'a',
  assessmentId: 'v',
  studentId: 's',
  status: 'IN_PROGRESS',
  exerciseAttempts: [_args('READING_SPEAKING').exerciseAttempt],
);
AttemptExerciseArgs _args(String type) => AttemptExerciseArgs(
  attemptId: 'a',
  exerciseIndex: 1,
  totalExercises: 4,
  exerciseAttempt: ExerciseAttempt(
    exerciseAttemptId: 'e',
    type: type,
    title: 'Actividad',
    prompt: type == 'READING_SPEAKING'
        ? 'Lee el texto en voz alta.'
        : type == 'READING_WRITING'
        ? 'Escribe el texto con tu dedo.'
        : type == 'ORDER_SYLLABLES'
        ? 'Toca las sílabas en orden.'
        : 'Elige la palabra que corresponde.',
    textToShow: 'El sol brilla en el cielo azul y las aves cantan.',
    syllables: const ['sa', 'ca'],
    mcOptions: const [
      MCOption(optionId: '1', text: 'casa', orderIndex: 1),
      MCOption(optionId: '2', text: 'cosa', orderIndex: 2),
    ],
  ),
);
Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  Object? arguments,
  Size size = const Size(390, 844),
  double scale = 1,
  double keyboard = 0,
}) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme.copyWith(
        textTheme: AppTheme.lightTheme.textTheme.apply(fontFamily: 'Roboto'),
        filledButtonTheme: FilledButtonThemeData(
          style: AppTheme.lightTheme.filledButtonTheme.style!.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Roboto', fontSize: 16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppTheme.lightTheme.outlinedButtonTheme.style!.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Roboto', fontSize: 16),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppTheme.lightTheme.textButtonTheme.style!.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Roboto', fontSize: 14),
            ),
          ),
        ),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: RepaintBoundary(key: const ValueKey('capture'), child: child!),
      ),
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        settings: RouteSettings(arguments: arguments),
        builder: (_) => page,
      ),
    ),
  );
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (Platform.environment['TAMIZIA_CAPTURE_UI'] != '1') return;
  final screens = Platform.environment['TAMIZIA_CAPTURE_UI_SCREENS'];
  if (screens != null && !screens.split(',').contains(name)) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('capture')),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(
      Platform.environment['TAMIZIA_CAPTURE_UI_DIR'] ?? 'docs/ui_review',
    )..createSync(recursive: true);
    await File(
      '${dir.path}/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Fredoka',
    )..addFont(rootBundle.load('assets/fonts/fredoka/Fredoka.ttf'))).load();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root != null) {
      final loader = FontLoader('Roboto');
      for (final name in [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ]) {
        final file = File('$root/bin/cache/artifacts/material_fonts/$name');
        if (file.existsSync()) {
          loader.addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())),
          );
        }
      }
      await loader.load();
      final fallback = File(
        '$root/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
      );
      if (fallback.existsSync()) {
        await (FontLoader('Ahem')..addFont(
              Future.value(ByteData.sublistView(fallback.readAsBytesSync())),
            ))
            .load();
      }
      final iconFile = File(
        '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      );
      if (iconFile.existsSync()) {
        await (FontLoader('MaterialIcons')..addFont(
              Future.value(ByteData.sublistView(iconFile.readAsBytesSync())),
            ))
            .load();
      }
    }
  });
  for (final configuration in [
    (const Size(390, 844), 1.0),
    (const Size(320, 640), 2.0),
    (const Size(800, 1100), 1.0),
    (const Size(844, 390), 1.0),
  ]) {
    final (size, scale) = configuration;
    testWidgets('all redesigned screens reflow at ${size.width} / $scale', (
      tester,
    ) async {
      final session = _session();
      final classrooms = _Classrooms();
      final students = _Students();
      final assessments = _Assessments();
      final pages = <(String, Widget, Object?)>[
        ('splash', const SplashPage(), null),
        ('login', LoginPage(sessionManager: session), null),
        ('register', RegisterPage(sessionManager: session), null),
        ('recovery', ForgotPasswordPage(authRepository: _Auth()), null),
        (
          'reset',
          ResetPasswordPage(authRepository: _Auth(), token: 'test'),
          null,
        ),
        (
          'dashboard',
          TeacherHomePage(
            dashboardSummaryService: _Dashboard(),
            sessionManager: session,
          ),
          null,
        ),
        ('profile', TeacherProfilePage(sessionManager: session), null),
        ('classrooms', ClassroomsPage(classroomRepository: classrooms), null),
        (
          'classroom',
          ClassroomDetailPage(
            classroomRepository: classrooms,
            studentRepository: students,
          ),
          'c',
        ),
        (
          'create_classroom',
          CreateClassroomPage(classroomRepository: classrooms),
          null,
        ),
        (
          'edit_classroom',
          EditClassroomPage(classroomRepository: classrooms),
          'c',
        ),
        (
          'students',
          StudentsListPage(
            studentRepository: students,
            classroomRepository: classrooms,
          ),
          null,
        ),
        (
          'student',
          StudentDetailPage(
            studentRepository: students,
            classroomRepository: classrooms,
          ),
          's',
        ),
        (
          'create_student',
          CreateStudentPage(studentRepository: students),
          {'classroomId': 'c', 'classroomName': 'Exploradores'},
        ),
        ('edit_student', EditStudentPage(studentRepository: students), 's'),
        (
          'exercises',
          ExerciseCatalogPage(exerciseService: MockExerciseService()),
          null,
        ),
        (
          'exercise',
          ExerciseDetailPage(exerciseService: MockExerciseService()),
          'visual-vocabulary',
        ),
        (
          'templates',
          TemplateCatalogPage(assessmentRepository: assessments),
          null,
        ),
        (
          'template',
          TemplateDetailPage(assessmentRepository: assessments),
          'p',
        ),
        (
          'config',
          AssessmentConfigPage(
            classroomRepository: classrooms,
            studentRepository: students,
            assessmentRepository: assessments,
          ),
          'p',
        ),
        (
          'preview',
          const AssessmentAttemptPreviewPage(),
          AssessmentAttemptPreview(
            classroom: _classroom,
            student: _student,
            template: _template,
            assessment: const Assessment(
              assessmentId: 'v',
              classroomId: 'c',
              templateId: 'p',
            ),
            attempt: _attempt(),
            hasValidConsent: true,
          ),
        ),
        ('session', AttemptSessionPage(assessmentRepository: assessments), 'a'),
        (
          'instructions',
          StudentInstructionsPage(
            exerciseService: MockExerciseService(),
            assessmentService: _LegacyAssessment(),
          ),
          const AssessmentSession(
            id: 'a',
            classroomId: 'c',
            studentId: 's',
            exerciseId: 'reading-aloud',
            type: AssessmentType.reading,
            status: 'IN_PROGRESS',
            estimatedDurationMinutes: 15,
          ),
        ),
        (
          'reading',
          ReadingAssessmentPage(assessmentRepository: assessments),
          _args('READING_SPEAKING'),
        ),
        (
          'writing',
          WritingAssessmentPage(assessmentRepository: assessments),
          _args('READING_WRITING'),
        ),
        (
          'choose',
          ChooseWordPage(assessmentRepository: assessments),
          _args('MULTIPLE_CHOICE'),
        ),
        (
          'syllables',
          BuildWordPage(assessmentRepository: assessments),
          _args('ORDER_SYLLABLES'),
        ),
        ('result', const AssessmentResultPage(), _result),
        (
          'review',
          AttemptReviewPage(assessmentRepository: assessments, attemptId: 'a'),
          null,
        ),
        (
          'history',
          StudentHistoryPage(assessmentRepository: assessments, studentId: 's'),
          null,
        ),
        ('error', const AssessmentErrorPage(), null),
        ('comparison', const TextComparisonPage(), null),
      ];
      for (final (name, page, args) in pages) {
        debugPrint('Checking $name at $size / $scale');
        await _pump(tester, page, arguments: args, size: size, scale: scale);
        expect(
          tester.takeException(),
          isNull,
          reason: '$name initial layout at $size / $scale',
        );
        if (name == 'result') {
          expect(find.text('72.5%'), findsNothing);
          await tester.tap(find.text('Docente: ver resultados'));
          await tester.pumpAndSettle();
          expect(find.text('72.5%'), findsOneWidget);
        }
        if (size.width == 390) await _capture(tester, name);
        // Exercise scrollable content too, not only the initial viewport.
        final scrolls = tester
            .stateList<ScrollableState>(find.byType(Scrollable))
            .toList();
        for (final scroll in scrolls) {
          if (scroll.position.hasContentDimensions &&
              scroll.position.maxScrollExtent > 0) {
            scroll.position.jumpTo(scroll.position.maxScrollExtent);
          }
        }
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$name scrolled layout at $size / $scale',
        );
        if (size.width == 390) await _capture(tester, '${name}_bottom');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
      session.dispose();
      await tester.binding.setSurfaceSize(null);
    });
  }
  for (final configuration in [
    (const Size(390, 844), 1.0, 0.0),
    (const Size(320, 640), 2.0, 0.0),
    (const Size(390, 844), 1.5, 280.0),
  ]) {
    testWidgets(
      'classroom fields remain visible before actions at $configuration',
      (tester) async {
        final (size, scale, keyboard) = configuration;
        await _pump(
          tester,
          CreateClassroomPage(classroomRepository: _Classrooms()),
          size: size,
          scale: scale,
          keyboard: keyboard,
        );
        final name = find.byType(TextFormField).first;
        expect(name.hitTestable(), findsOneWidget);
        expect(tester.getTopLeft(name).dy, greaterThan(48));
        await tester.enterText(name, 'Exploradores');
        final dropdowns = find.byType(DropdownButtonFormField<String>);
        for (var i = 0; i < 3; i++) {
          await tester.ensureVisible(dropdowns.at(i));
          await tester.pumpAndSettle();
          expect(dropdowns.at(i).hitTestable(), findsOneWidget);
        }
        final save = find.text('Guardar');
        expect(
          tester.getTopLeft(save).dy,
          greaterThan(tester.getBottomLeft(dropdowns.last).dy),
        );
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.text('Selecciona un grado.'), findsOneWidget);
        expect(find.text('Exploradores'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.binding.setSurfaceSize(null);
      },
    );
  }
  testWidgets(
    'review exposes reading and writing indicators with their evidence',
    (tester) async {
      await _pump(
        tester,
        AttemptReviewPage(assessmentRepository: _Assessments(), attemptId: 'a'),
      );
      for (final entry in [
        ('Indicadores de lectura', 'review_reading_metrics'),
        ('Indicadores de escritura', 'review_writing_metrics'),
      ]) {
        await tester.ensureVisible(find.text(entry.$1));
        await tester.pumpAndSettle();
        expect(find.text(entry.$1).hitTestable(), findsOneWidget);
        await _capture(tester, entry.$2);
      }
      expect(find.text('7.1%'), findsOneWidget);
      expect(find.text('33.3%'), findsOneWidget);
      expect(find.text('74.8%'), findsOneWidget);
      expect(find.text('80.2 / 100'), findsOneWidget);
      expect(
        find.text('No se incluye en el cálculo del resultado.'),
        findsOneWidget,
      );
      expect(find.text('Requiere revisión docente'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets('form works with keyboard and text scaling', (tester) async {
    final session = _session();
    await _pump(
      tester,
      LoginPage(sessionManager: session),
      size: const Size(320, 640),
      scale: 1.5,
      keyboard: 280,
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'docente@example.test',
    );
    await tester.ensureVisible(find.byType(PrimaryButton).first);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    session.dispose();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('word choice communicates selection to assistive technology', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      Scaffold(
        body: SelectableWordCard(text: 'casa', selected: true, onTap: () {}),
      ),
      scale: 2,
      size: const Size(320, 640),
    );
    expect(
      tester.getSemantics(find.byType(SelectableWordCard)),
      matchesSemantics(
        label: 'casa',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('writing still captures a continuous stroke', (tester) async {
    await _pump(
      tester,
      WritingAssessmentPage(assessmentRepository: _Assessments()),
      arguments: _args('READING_WRITING'),
    );
    final canvas = find.byType(DrawingCanvasPlaceholder);
    await tester.ensureVisible(canvas);
    await tester.dragFrom(
      tester.getTopLeft(canvas) + const Offset(40, 60),
      const Offset(130, 30),
    );
    await tester.pump();
    final widget = tester.widget<DrawingCanvasPlaceholder>(canvas);
    expect(widget.strokes, isNotEmpty);
    expect(widget.strokes.first.points.length, greaterThan(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1024, 1366),
  ]) {
    testWidgets('writing owns vertical strokes and dots at $size', (
      tester,
    ) async {
      await _pump(
        tester,
        WritingAssessmentPage(assessmentRepository: _Assessments()),
        arguments: _args('READING_WRITING'),
        size: size,
      );
      final canvas = find.byType(DrawingCanvasPlaceholder);
      expect(tester.getSize(canvas).height, greaterThanOrEqualTo(480));
      await tester.ensureVisible(canvas);
      await tester.pumpAndSettle();
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      final initialOffset = scroll.position.pixels;
      final start = tester.getTopLeft(canvas) + const Offset(60, 160);
      for (final delta in [
        const Offset(0, -90),
        const Offset(0, 90),
        const Offset(90, 0),
        const Offset(60, -60),
      ]) {
        final gesture = await tester.startGesture(start);
        await tester.pump();
        await gesture.moveBy(delta / 2);
        await tester.pump();
        await gesture.moveBy(delta / 2);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(scroll.position.pixels, initialOffset);
        final stroke = tester
            .widget<DrawingCanvasPlaceholder>(canvas)
            .strokes
            .last;
        expect(stroke.points.length, greaterThanOrEqualTo(3));
        expect(stroke.points.last.offset - stroke.points.first.offset, delta);
      }
      await tester.tapAt(start);
      await tester.pump();
      expect(
        tester.widget<DrawingCanvasPlaceholder>(canvas).strokes.last.points,
        hasLength(1),
      );
      // The page must still scroll when dragging in the margin outside the pad.
      if (scroll.position.maxScrollExtent > 0) {
        await tester.dragFrom(
          Offset(tester.getTopLeft(canvas).dx - 12, start.dy),
          Offset(0, initialOffset > 0 ? 100 : -100),
        );
        await tester.pumpAndSettle();
        expect(scroll.position.pixels, isNot(initialOffset));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    });
  }
  testWidgets(
    'writing ignores a second finger and recovers after cancellation',
    (tester) async {
      await _pump(
        tester,
        WritingAssessmentPage(assessmentRepository: _Assessments()),
        arguments: _args('READING_WRITING'),
      );
      final canvas = find.byType(DrawingCanvasPlaceholder);
      await tester.ensureVisible(canvas);
      final start = tester.getTopLeft(canvas) + const Offset(60, 100);
      final first = await tester.startGesture(start, pointer: 1);
      final second = await tester.startGesture(
        start + const Offset(40, 0),
        pointer: 2,
      );
      await second.moveBy(const Offset(0, 40));
      await second.up();
      await first.moveBy(const Offset(0, 50));
      await tester.pump();
      expect(
        tester.widget<DrawingCanvasPlaceholder>(canvas).strokes,
        hasLength(1),
      );
      await first.cancel();
      await tester.tapAt(start);
      await tester.pump();
      expect(
        tester.widget<DrawingCanvasPlaceholder>(canvas).strokes,
        hasLength(2),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'empty and incomplete results stay readable without invented scores',
    (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const AssessmentResultSummary(
                  score: null,
                  level: null,
                  pending: 3,
                ),
                AppEmptyState(
                  title: 'Aún no hay estudiantes',
                  message: 'Registra al primer estudiante para comenzar.',
                  actionLabel: 'Registrar estudiante',
                  onAction: () {},
                ),
              ],
            ),
          ),
        ),
        size: const Size(320, 640),
        scale: 2,
      );
      expect(find.text('Sin puntaje disponible'), findsOneWidget);
      expect(find.text('0.0%'), findsNothing);
      expect(find.textContaining('3 ejercicios pendientes'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'dashboard shortcuts lead to existing classroom and history entry points',
    (tester) async {
      final session = _session();
      for (final action in [
        ('Registrar en un aula', AppRoutes.classrooms),
        ('Historial de estudiantes', AppRoutes.studentsList),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: TeacherHomePage(
              dashboardSummaryService: _Dashboard(),
              sessionManager: session,
            ),
            routes: {
              action.$2: (_) => Scaffold(body: Text('Destino ${action.$2}')),
            },
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(action.$1));
        await tester.tap(find.text(action.$1));
        await tester.pumpAndSettle();
        expect(find.text('Destino ${action.$2}'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      }
      session.dispose();
    },
  );
  test('semantic text colors meet normal text contrast on their surfaces', () {
    for (final pair in [
      (AppColors.textPrimary, AppColors.studentBackground),
      (AppColors.textSecondary, AppColors.background),
      (AppColors.surface, AppColors.primary),
      (AppColors.secondary, AppColors.secondaryContainer),
      (AppColors.success, AppColors.successContainer),
      (AppColors.warning, AppColors.warningContainer),
      (AppColors.error, AppColors.errorContainer),
    ]) {
      final a = pair.$1.computeLuminance(), b = pair.$2.computeLuminance();
      final ratio =
          (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });
}
