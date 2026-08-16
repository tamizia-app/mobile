import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/app.dart';
import 'package:tamizai_app/core/constants/app_strings.dart';
import 'package:tamizai_app/core/session/auth_session_manager.dart';
import 'package:tamizai_app/core/storage/auth_session_storage.dart';
import 'package:tamizai_app/core/widgets/app_header.dart';
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
    expect(tester.getSize(find.byType(TeacherGreetingHeader)).height, 104);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigates through the initial auth screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('TamizIA'), findsOneWidget);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginButton), findsNWidgets(2));
    await tester.tap(find.text(AppStrings.createTeacherAccount));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.registerTitle), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
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
    expect(find.textContaining('Accesos'), findsOneWidget);
  });
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
