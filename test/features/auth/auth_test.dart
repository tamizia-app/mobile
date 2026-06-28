import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/network/api_client.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/core/session/auth_session_manager.dart';
import 'package:tamizai_app/core/session/authentication_status.dart';
import 'package:tamizai_app/core/storage/auth_session_storage.dart';
import 'package:tamizai_app/core/storage/secure_auth_session_storage.dart';
import 'package:tamizai_app/core/validators/auth_validators.dart';
import 'package:tamizai_app/features/auth/data/models/forgot_password_request_dto.dart';
import 'package:tamizai_app/features/auth/data/models/refresh_request_dto.dart';
import 'package:tamizai_app/features/auth/data/models/reset_password_request_dto.dart';
import 'package:tamizai_app/features/auth/data/models/signout_request_dto.dart';
import 'package:tamizai_app/features/auth/data/models/signup_request_dto.dart';
import 'package:tamizai_app/features/auth/domain/entities/auth_session.dart';
import 'package:tamizai_app/features/auth/domain/models/login_request.dart';
import 'package:tamizai_app/features/auth/domain/models/register_request.dart';
import 'package:tamizai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tamizai_app/features/auth/presentation/viewmodels/forgot_password_viewmodel.dart';
import 'package:tamizai_app/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:tamizai_app/features/auth/presentation/viewmodels/reset_password_viewmodel.dart';
import 'package:tamizai_app/features/teacher/domain/models/teacher_profile.dart';
import 'package:tamizai_app/features/teacher/domain/models/update_teacher_profile_request.dart';
import 'package:tamizai_app/features/teacher/domain/repositories/teacher_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth contracts', () {
    test('request DTOs use exactly the documented keys', () {
      expect(RefreshRequestDto(refreshToken: 'r').toJson(), {
        'refresh_token': 'r',
      });
      expect(SignoutRequestDto(refreshToken: 'r').toJson(), {
        'refresh_token': 'r',
      });
      expect(ForgotPasswordRequestDto(email: 'a@b.com').toJson(), {
        'email': 'a@b.com',
      });
      expect(
        const ResetPasswordRequestDto(
          token: 't',
          newPassword: 'Password123',
        ).toJson(),
        {'token': 't', 'new_password': 'Password123'},
      );
    });

    test('signup excludes confirmation and terms fields', () {
      expect(SignupRequestDto.fromDomain(_registerRequest()).toJson(), {
        'name': 'Ada',
        'lastname': 'Lovelace',
        'email': 'ada@example.com',
        'password': 'Password123',
        'institute_name': 'Colegio Test',
        'phone': '987654321',
      });
    });
  });

  group('SecureAuthSessionStorage', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test(
      'saves and restores the complete session including expiresAt',
      () async {
        final storage = SecureAuthSessionStorage();
        final session = _session(access: 'access-one', refresh: 'refresh-one');

        await storage.saveSession(session);
        final restored = await storage.readSession();

        expect(restored?.accessToken, 'access-one');
        expect(restored?.refreshToken, 'refresh-one');
        expect(restored?.tokenType, 'bearer');
        expect(restored?.expiresIn, 28800);
        expect(restored?.expiresAt.toUtc(), session.expiresAt.toUtc());
      },
    );

    test('clears the complete session', () async {
      final storage = SecureAuthSessionStorage();
      await storage.saveSession(_session());
      await storage.clearSession();
      expect(await storage.readSession(), isNull);
    });
  });

  group('AuthSessionManager', () {
    test('initializes unauthenticated without a stored session', () async {
      final fixture = _fixture();
      await fixture.manager.initialize();
      expect(fixture.manager.status, AuthenticationStatus.unauthenticated);
      expect(fixture.teacher.getCalls, 0);
    });

    test('restores a valid session and loads the teacher', () async {
      final fixture = _fixture(storedSession: _session());
      await fixture.manager.initialize();
      expect(fixture.manager.status, AuthenticationStatus.authenticated);
      expect(fixture.manager.currentTeacher?.name, 'Ada');
      expect(fixture.teacher.getCalls, 1);
    });

    test('refreshes an expiring session and replaces both tokens', () async {
      final old = _session(
        access: 'old-access',
        refresh: 'old-refresh',
        expiresAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      final fresh = _session(access: 'new-access', refresh: 'new-refresh');
      final fixture = _fixture(storedSession: old, refreshedSession: fresh);

      await fixture.manager.initialize();

      expect(fixture.auth.refreshTokens, ['old-refresh']);
      expect(fixture.manager.session?.accessToken, 'new-access');
      expect(fixture.manager.session?.refreshToken, 'new-refresh');
      expect(fixture.storage.session?.refreshToken, 'new-refresh');
    });

    test('shares one refresh between simultaneous callers', () async {
      final completer = Completer<AuthSession>();
      final fixture = _fixture(storedSession: _session());
      await fixture.manager.initialize();
      fixture.auth.refreshCompleter = completer;

      final first = fixture.manager.refreshSession();
      final second = fixture.manager.refreshSession();
      expect(fixture.auth.refreshTokens.length, 1);
      completer.complete(_session(refresh: 'rotated'));

      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(fixture.auth.refreshTokens.length, 1);
      expect(fixture.manager.session?.refreshToken, 'rotated');
    });

    test('clears session and teacher when refresh is unauthorized', () async {
      final fixture = _fixture(storedSession: _session());
      await fixture.manager.initialize();
      fixture.auth.refreshError = const UnauthorizedException('expired');

      expect(await fixture.manager.refreshSession(), isFalse);
      expect(fixture.manager.session, isNull);
      expect(fixture.manager.currentTeacher, isNull);
      expect(fixture.storage.session, isNull);
      expect(fixture.manager.status, AuthenticationStatus.unauthenticated);
    });

    test('clears session when refresh fails due to network', () async {
      final fixture = _fixture(storedSession: _session());
      await fixture.manager.initialize();
      fixture.auth.refreshError = const NetworkException('offline');

      expect(await fixture.manager.refreshSession(), isFalse);
      expect(fixture.storage.session, isNull);
      expect(fixture.manager.status, AuthenticationStatus.unauthenticated);
    });

    test('signin stores the full session and loads the teacher', () async {
      final fixture = _fixture();
      final viewModel = LoginViewModel(sessionManager: fixture.manager)
        ..email = 'ada@example.com'
        ..password = 'Password123';

      expect(await viewModel.login(), isTrue);
      expect(fixture.storage.session?.accessToken, 'access');
      expect(fixture.storage.session?.refreshToken, 'refresh');
      expect(fixture.storage.session?.tokenType, 'bearer');
      expect(fixture.storage.session?.expiresAt, isNotNull);
      expect(fixture.manager.currentTeacher?.teacherId, 'teacher-id');
    });

    test('signout calls backend then clears session and teacher', () async {
      final fixture = _fixture(storedSession: _session());
      await fixture.manager.initialize();

      await fixture.manager.signOut();

      expect(fixture.auth.signOutTokens, ['refresh']);
      expect(fixture.storage.session, isNull);
      expect(fixture.manager.currentTeacher, isNull);
      expect(fixture.manager.status, AuthenticationStatus.unauthenticated);
    });

    test('signout still clears locally when backend fails', () async {
      final fixture = _fixture(storedSession: _session());
      await fixture.manager.initialize();
      fixture.auth.signOutError = const NetworkException('offline');

      await fixture.manager.signOut();

      expect(fixture.storage.session, isNull);
      expect(fixture.manager.status, AuthenticationStatus.unauthenticated);
    });
  });

  group('Password flows', () {
    test(
      'forgot password validates email and shows neutral response',
      () async {
        final auth = _FakeAuthRepository();
        final viewModel = ForgotPasswordViewModel(authRepository: auth)
          ..email = 'ada@example.com';

        expect(await viewModel.sendRecoveryLink(), isTrue);
        expect(auth.forgotEmails, ['ada@example.com']);
        expect(viewModel.successMessage, contains('Si el correo existe'));
      },
    );

    test('reset sends only token and new password', () async {
      final auth = _FakeAuthRepository();
      final viewModel =
          ResetPasswordViewModel(authRepository: auth, token: 'reset-token')
            ..newPassword = 'Password123'
            ..confirmPassword = 'Password123';

      expect(await viewModel.resetPassword(), isTrue);
      expect(auth.resetRequests, [
        {'token': 'reset-token', 'new_password': 'Password123'},
      ]);
    });

    test('reset rejects missing token and mismatched passwords', () async {
      final auth = _FakeAuthRepository();
      final missingToken =
          ResetPasswordViewModel(authRepository: auth, token: '')
            ..newPassword = 'Password123'
            ..confirmPassword = 'Password123';
      expect(await missingToken.resetPassword(), isFalse);

      final mismatch =
          ResetPasswordViewModel(authRepository: auth, token: 'token')
            ..newPassword = 'Password123'
            ..confirmPassword = 'Password456';
      expect(await mismatch.resetPassword(), isFalse);
      expect(auth.resetRequests, isEmpty);
    });
  });

  group('ApiClient auth interceptor', () {
    test('adds bearer, refreshes one time, and retries the request', () async {
      final client = ApiClient();
      final adapter = _SequenceAdapter([401, 200]);
      client.dio.httpClientAdapter = adapter;
      var token = 'old-access';
      var refreshCalls = 0;
      client.configureAuthentication(
        accessTokenProvider: () async => token,
        refreshSession: () async {
          refreshCalls++;
          token = 'new-access';
          return true;
        },
      );

      final response = await client.dio.get<Map<String, dynamic>>(
        '/api/v1/teachers/me',
      );

      expect(response.statusCode, 200);
      expect(refreshCalls, 1);
      expect(adapter.calls, 2);
      expect(adapter.authorizationHeaders, [
        'Bearer old-access',
        'Bearer new-access',
      ]);
    });

    test('does not attach bearer to public auth endpoints', () async {
      final client = ApiClient();
      final adapter = _SequenceAdapter([200]);
      client.dio.httpClientAdapter = adapter;
      client.configureAuthentication(
        accessTokenProvider: () async => 'secret',
        refreshSession: () async => true,
      );

      await client.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/forgot-password',
        data: {'email': 'ada@example.com'},
      );

      expect(adapter.authorizationHeaders, [isNull]);
    });
  });

  group('Validators', () {
    test('validates phone, email, and matching passwords', () {
      expect(AuthValidators.validatePhone('+51987654321'), isNull);
      expect(AuthValidators.validatePhone('abc987'), isNotNull);
      expect(AuthValidators.validateEmail('invalid'), isNotNull);
      expect(
        AuthValidators.validateConfirmPassword('Password2', 'Password1'),
        isNotNull,
      );
    });
  });
}

_Fixture _fixture({AuthSession? storedSession, AuthSession? refreshedSession}) {
  final auth = _FakeAuthRepository(
    signInSession: _session(),
    signUpSession: _session(),
    refreshedSession: refreshedSession ?? _session(refresh: 'rotated'),
  );
  final teacher = _FakeTeacherRepository();
  final storage = _MemorySessionStorage()..session = storedSession;
  final manager = AuthSessionManager(
    authRepository: auth,
    teacherRepository: teacher,
    sessionStorage: storage,
  );
  return _Fixture(manager, auth, teacher, storage);
}

class _Fixture {
  const _Fixture(this.manager, this.auth, this.teacher, this.storage);

  final AuthSessionManager manager;
  final _FakeAuthRepository auth;
  final _FakeTeacherRepository teacher;
  final _MemorySessionStorage storage;
}

AuthSession _session({
  String access = 'access',
  String refresh = 'refresh',
  DateTime? expiresAt,
}) {
  return AuthSession(
    accessToken: access,
    refreshToken: refresh,
    tokenType: 'bearer',
    expiresIn: 28800,
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 8)),
  );
}

RegisterRequest _registerRequest() {
  return const RegisterRequest(
    names: 'Ada',
    lastNames: 'Lovelace',
    email: 'ada@example.com',
    password: 'Password123',
    confirmPassword: 'Password123',
    institution: 'Colegio Test',
    phone: '987654321',
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.signInSession,
    this.signUpSession,
    this.refreshedSession,
  });

  AuthSession? signInSession;
  AuthSession? signUpSession;
  AuthSession? refreshedSession;
  Completer<AuthSession>? refreshCompleter;
  ApiException? refreshError;
  ApiException? signOutError;
  final List<String> refreshTokens = [];
  final List<String> signOutTokens = [];
  final List<String> forgotEmails = [];
  final List<Map<String, String>> resetRequests = [];

  @override
  Future<AuthSession> signIn(LoginRequest request) async {
    return signInSession ?? _session();
  }

  @override
  Future<AuthSession> signUp(RegisterRequest request) async {
    return signUpSession ?? _session();
  }

  @override
  Future<AuthSession> refresh(String refreshToken) {
    refreshTokens.add(refreshToken);
    final error = refreshError;
    if (error != null) {
      throw error;
    }
    return refreshCompleter?.future ??
        Future.value(refreshedSession ?? _session(refresh: 'rotated'));
  }

  @override
  Future<void> signOut(String refreshToken) async {
    signOutTokens.add(refreshToken);
    final error = signOutError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    forgotEmails.add(email);
    return 'If the email exists, a reset token has been sent.';
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    resetRequests.add({'token': token, 'new_password': newPassword});
    return 'Password has been reset successfully.';
  }
}

class _FakeTeacherRepository implements TeacherRepository {
  int getCalls = 0;
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
  Future<TeacherProfile> getMyProfile() async {
    getCalls++;
    return profile;
  }

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

class _MemorySessionStorage implements AuthSessionStorage {
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

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this.statuses);

  final List<int> statuses;
  final List<String?> authorizationHeaders = [];
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    final status = statuses[calls++];
    final body = status == 200 ? '{"ok":true}' : '{"detail":"expired"}';
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
