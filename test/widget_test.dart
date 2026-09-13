import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/app.dart';
import 'package:tamizai_app/core/constants/app_strings.dart';
import 'package:tamizai_app/core/session/auth_session_manager.dart';
import 'package:tamizai_app/core/storage/auth_session_storage.dart';
import 'package:tamizai_app/core/widgets/app_header.dart';
import 'package:tamizai_app/core/widgets/metric_card.dart';
import 'package:tamizai_app/core/widgets/responsive_layout.dart';
import 'package:tamizai_app/features/auth/domain/entities/auth_session.dart';
import 'package:tamizai_app/features/auth/domain/models/login_request.dart';
import 'package:tamizai_app/features/auth/domain/models/register_request.dart';
import 'package:tamizai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamizai_app/features/teacher/domain/models/teacher_profile.dart';
import 'package:tamizai_app/features/teacher/domain/models/update_teacher_profile_request.dart';
import 'package:tamizai_app/features/teacher/domain/repositories/teacher_repository.dart';

void main() {
  testWidgets('teacher header keeps its content below the status bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 860),
            padding: EdgeInsets.only(top: 40),
          ),
          child: Scaffold(
            body: Column(children: [TeacherGreetingHeader(name: 'Sandro')]),
          ),
        ),
      ),
    );

    expect(find.text('Hola, Sandro'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Hola, Sandro')).dy,
      greaterThanOrEqualTo(40),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigates through the initial auth screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Logo de TamizIA'), findsOneWidget);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginButton), findsNWidgets(2));
    await tester.tap(find.text(AppStrings.createTeacherAccount));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.registerTitle), findsOneWidget);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.forgotPasswordLink));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.forgotPasswordTitle), findsOneWidget);
  });

  testWidgets('validates required login fields', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, AppStrings.loginButton));
    await tester.pump();

    expect(find.textContaining('es obligatorio'), findsOneWidget);
  });

  testWidgets('successful login loads teacher and opens dashboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'ejemplo@escuela.edu'),
      'docente@escuela.edu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'password123'),
      'Password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.loginButton));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Ada'), findsOneWidget);
    expect(find.text('Tu espacio de trabajo'), findsOneWidget);
    _expectEqualMetricSizes(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts the dashboard to a tablet viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'ejemplo@escuela.edu'),
      'docente@escuela.edu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'password123'),
      'Password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.loginButton));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(Scaffold).first).width,
      AppBreakpoints.maxAppWidth,
    );
    _expectEqualMetricSizes(tester);
    final metricPositions =
        [
              'A tu cargo',
              'Activos en tus aulas',
              'Creadas por ti',
              'Intentos sin finalizar',
            ]
            .map(
              (label) => tester.getTopLeft(
                find.ancestor(
                  of: find.text(label),
                  matching: find.byWidgetPredicate(
                    (widget) => widget is MetricCard,
                  ),
                ),
              ),
            )
            .toList();
    expect(metricPositions.map((position) => position.dy).toSet().length, 1);
    for (var index = 1; index < metricPositions.length; index++) {
      expect(
        metricPositions[index].dx,
        greaterThan(metricPositions[index - 1].dx),
      );
    }
    expect(tester.takeException(), isNull);
  });
}

void _expectEqualMetricSizes(WidgetTester tester) {
  final cards = find.byWidgetPredicate((widget) => widget is MetricCard);
  expect(cards, findsNWidgets(4));
  final expectedSize = tester.getSize(cards.first);
  expect(expectedSize.width, greaterThan(100));
  for (var index = 1; index < 4; index++) {
    expect(tester.getSize(cards.at(index)).width, expectedSize.width);
  }
}

Widget _app() {
  return TamiziaApp(
    sessionManager: AuthSessionManager(
      authRepository: _AuthRepository(),
      teacherRepository: _TeacherRepository(),
      sessionStorage: _Storage(),
    ),
  );
}

class _AuthRepository implements AuthRepository {
  @override
  Future<AuthSession> signIn(LoginRequest request) async => _session();

  @override
  Future<AuthSession> signUp(RegisterRequest request) async => _session();

  @override
  Future<AuthSession> refresh(String refreshToken) async => _session();

  @override
  Future<void> signOut(String refreshToken) async {}

  @override
  Future<String> forgotPassword(String email) async => 'message';

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async => 'message';
}

class _TeacherRepository implements TeacherRepository {
  @override
  Future<TeacherProfile> getMyProfile() async {
    return const TeacherProfile(
      teacherId: 'teacher-id',
      name: 'Ada',
      lastname: 'Lovelace',
      email: 'ada@example.com',
      instituteName: 'Colegio Test',
      phone: '987654321',
    );
  }

  @override
  Future<TeacherProfile> updateMyProfile(
    UpdateTeacherProfileRequest request,
  ) async {
    return TeacherProfile(
      teacherId: 'teacher-id',
      name: request.name,
      lastname: request.lastname,
      email: request.email,
      instituteName: request.instituteName,
      phone: request.phone,
    );
  }
}

class _Storage implements AuthSessionStorage {
  AuthSession? session;

  @override
  Future<void> clearSession() async => session = null;

  @override
  Future<AuthSession?> readSession() async => session;

  @override
  Future<void> saveSession(AuthSession session) async {
    this.session = session;
  }
}

AuthSession _session() {
  return AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'bearer',
    expiresIn: 28800,
    expiresAt: DateTime.now().add(const Duration(hours: 8)),
  );
}
