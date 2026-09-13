import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/session/auth_session_manager.dart';
import 'package:tamizai_app/core/storage/auth_session_storage.dart';
import 'package:tamizai_app/features/auth/domain/entities/auth_session.dart';
import 'package:tamizai_app/features/auth/domain/models/login_request.dart';
import 'package:tamizai_app/features/auth/domain/models/register_request.dart';
import 'package:tamizai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamizai_app/features/teacher/data/models/teacher_profile_dto.dart';
import 'package:tamizai_app/features/teacher/data/models/update_teacher_profile_request_dto.dart';
import 'package:tamizai_app/features/teacher/domain/models/teacher_profile.dart';
import 'package:tamizai_app/features/teacher/domain/models/update_teacher_profile_request.dart';
import 'package:tamizai_app/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:tamizai_app/features/teacher/presentation/pages/teacher_profile_page.dart';
import 'package:tamizai_app/features/teacher/presentation/viewmodels/teacher_profile_viewmodel.dart';

void main() {
  group('Teacher contracts', () {
    test('parses the exact teacher response including teacher_id', () {
      final profile = TeacherProfileDto.fromJson({
        'teacher_id': '2a1b5909-e081-4cc9-b313-a1d349dec2da',
        'name': 'Joseph Alexis',
        'lastname': 'Huamani Mandujano',
        'email': 'joseph@example.com',
        'institute_name': 'upc',
        'phone': '936450356',
      }).toDomain();

      expect(profile.teacherId, '2a1b5909-e081-4cc9-b313-a1d349dec2da');
      expect(profile.fullName, 'Joseph Alexis Huamani Mandujano');
      expect(profile.instituteName, 'upc');
      expect(profile.phone, '936450356');
    });

    test('accepts nullable institute_name and phone from Swagger', () {
      final profile = TeacherProfileDto.fromJson({
        'teacher_id': 'teacher-id',
        'name': 'Ada',
        'lastname': 'Lovelace',
        'email': 'ada@example.com',
        'institute_name': null,
        'phone': null,
      }).toDomain();

      expect(profile.instituteName, isNull);
      expect(profile.phone, isNull);
    });

    test('PUT request uses exactly the documented fields', () {
      const request = UpdateTeacherProfileRequest(
        name: 'Ada',
        lastname: 'Lovelace',
        email: 'ada@example.com',
        instituteName: 'Colegio Test',
        phone: '987654321',
      );

      expect(UpdateTeacherProfileRequestDto.fromDomain(request).toJson(), {
        'name': 'Ada',
        'lastname': 'Lovelace',
        'email': 'ada@example.com',
        'institute_name': 'Colegio Test',
        'phone': '987654321',
      });
    });
  });

  group('Teacher global profile', () {
    test('loads profile after signin and updates the shared profile', () async {
      final auth = _AuthRepository();
      final teacher = _TeacherRepository();
      final storage = _Storage();
      final manager = AuthSessionManager(
        authRepository: auth,
        teacherRepository: teacher,
        sessionStorage: storage,
      );

      await manager.signIn('ada@example.com', 'Password123');
      expect(manager.currentTeacher?.name, 'Ada');

      await manager.updateCurrentTeacher(
        const UpdateTeacherProfileRequest(
          name: 'Grace',
          lastname: 'Hopper',
          email: 'grace@example.com',
          instituteName: 'Academia',
          phone: '999888777',
        ),
      );

      expect(manager.currentTeacher?.fullName, 'Grace Hopper');
      expect(manager.currentTeacher?.phone, '999888777');
      expect(teacher.updateCalls, 1);
    });

    test('profile ViewModel preloads and publishes backend update', () async {
      final teacher = _TeacherRepository();
      final manager = AuthSessionManager(
        authRepository: _AuthRepository(),
        teacherRepository: teacher,
        sessionStorage: _Storage(),
      );
      await manager.signIn('ada@example.com', 'Password123');
      final viewModel = TeacherProfileViewModel(sessionManager: manager);
      await viewModel.load();

      expect(viewModel.firstName, 'Ada');
      expect(viewModel.phone, '987654321');
      expect(viewModel.hasChanges, isFalse);
      expect(viewModel.canSave, isFalse);

      viewModel
        ..setFirstName('Katherine')
        ..setLastName('Johnson')
        ..setEmail('katherine@example.com')
        ..setInstitution('NASA Academy')
        ..setPhone('988777666');

      expect(await viewModel.save(), isTrue);
      expect(manager.currentTeacher?.fullName, 'Katherine Johnson');
      expect(manager.currentTeacher?.email, 'katherine@example.com');
      expect(viewModel.hasChanges, isFalse);
      expect(viewModel.canSave, isFalse);
    });

    test('detects normalized changes and does not PUT without them', () async {
      final teacher = _TeacherRepository();
      final manager = AuthSessionManager(
        authRepository: _AuthRepository(),
        teacherRepository: teacher,
        sessionStorage: _Storage(),
      );
      await manager.signIn('ada@example.com', 'Password123');
      final viewModel = TeacherProfileViewModel(sessionManager: manager);
      await viewModel.load();

      viewModel.setFirstName('  Ada  ');
      expect(viewModel.hasChanges, isFalse);
      expect(await viewModel.save(), isFalse);
      expect(teacher.updateCalls, 0);

      viewModel.setFirstName('Grace');
      expect(viewModel.hasChanges, isTrue);
      expect(viewModel.canSave, isTrue);

      viewModel.setFirstName('');
      expect(viewModel.hasChanges, isTrue);
      expect(viewModel.canSave, isFalse);

      viewModel.restore();
      expect(viewModel.firstName, 'Ada');
      expect(viewModel.hasChanges, isFalse);
      expect(viewModel.errorMessage, isNull);
    });
  });

  testWidgets('profile form preloads, toggles save, and cancels changes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    final teacher = _TeacherRepository();
    final manager = AuthSessionManager(
      authRepository: _AuthRepository(),
      teacherRepository: teacher,
      sessionStorage: _Storage(),
    );
    await manager.signIn('ada@example.com', 'Password123');

    await tester.pumpWidget(
      MaterialApp(home: TeacherProfilePage(sessionManager: manager)),
    );
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();
    expect(fields[0].controller?.text, 'Ada');
    expect(fields[1].controller?.text, 'Lovelace');
    expect(fields[2].controller?.text, 'ada@example.com');
    expect(fields[3].controller?.text, 'Colegio Test');
    expect(fields[4].controller?.text, '987654321');

    FilledButton saveButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar cambios'),
    );

    expect(saveButton().onPressed, isNull);
    await tester.enterText(find.byType(TextFormField).first, 'Grace');
    await tester.pump();
    expect(saveButton().onPressed, isNotNull);

    final cancelButton = find.widgetWithText(OutlinedButton, 'Cancelar');
    await tester.ensureVisible(cancelButton);
    await tester.tap(cancelButton);
    await tester.pump();
    expect(fields[0].controller?.text, 'Ada');
    expect(saveButton().onPressed, isNull);
    expect(teacher.updateCalls, 0);
  });
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
  int updateCalls = 0;
  TeacherProfile profile = const TeacherProfile(
    teacherId: 'teacher-id',
    name: 'Ada',
    lastname: 'Lovelace',
    email: 'ada@example.com',
    instituteName: 'Colegio Test',
    phone: '987654321',
  );

  @override
  Future<TeacherProfile> getMyProfile() async => profile;

  @override
  Future<TeacherProfile> updateMyProfile(
    UpdateTeacherProfileRequest request,
  ) async {
    updateCalls++;
    profile = TeacherProfile(
      teacherId: profile.teacherId,
      name: request.name,
      lastname: request.lastname,
      email: request.email,
      instituteName: request.instituteName,
      phone: request.phone,
    );
    return profile;
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
