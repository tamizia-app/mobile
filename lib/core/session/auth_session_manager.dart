import 'package:flutter/foundation.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/domain/models/login_request.dart';
import '../../features/auth/domain/models/register_request.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/teacher/domain/models/teacher_profile.dart';
import '../../features/teacher/domain/models/update_teacher_profile_request.dart';
import '../../features/teacher/domain/repositories/teacher_repository.dart';
import '../network/api_exception.dart';
import '../storage/auth_session_storage.dart';
import 'authentication_status.dart';

class AuthSessionManager extends ChangeNotifier {
  AuthSessionManager({
    required AuthRepository authRepository,
    required TeacherRepository teacherRepository,
    required AuthSessionStorage sessionStorage,
  }) : _authRepository = authRepository,
       _teacherRepository = teacherRepository,
       _sessionStorage = sessionStorage;

  final AuthRepository _authRepository;
  final TeacherRepository _teacherRepository;
  final AuthSessionStorage _sessionStorage;

  AuthenticationStatus status = AuthenticationStatus.unknown;
  AuthSession? session;
  TeacherProfile? currentTeacher;
  String? lastError;
  Future<bool>? _refreshFuture;

  bool get isInitializing => status == AuthenticationStatus.unknown;
  bool get isRefreshing => status == AuthenticationStatus.refreshing;
  bool get isAuthenticated =>
      status == AuthenticationStatus.authenticated ||
      status == AuthenticationStatus.refreshing;

  Future<void> initialize() async {
    status = AuthenticationStatus.unknown;
    notifyListeners();
    session = await _sessionStorage.readSession();
    if (session == null) {
      status = AuthenticationStatus.unauthenticated;
      notifyListeners();
      return;
    }

    if (session!.isExpiringSoon() && !await refreshSession()) {
      if (session == null) {
        return;
      }
      await _clearLocalSession();
      return;
    }

    status = AuthenticationStatus.authenticated;
    notifyListeners();
    try {
      await loadCurrentTeacher();
    } on ApiException catch (error) {
      lastError = error.message;
      if (error is UnauthorizedException || error is ForbiddenException) {
        await _clearLocalSession();
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    final newSession = await _authRepository.signIn(
      LoginRequest(email: email, password: password),
    );
    await _establishSession(newSession);
  }

  Future<void> signUp(RegisterRequest request) async {
    final newSession = await _authRepository.signUp(request);
    await _establishSession(newSession);
  }

  Future<void> _establishSession(AuthSession newSession) async {
    await _sessionStorage.saveSession(newSession);
    session = newSession;
    status = AuthenticationStatus.authenticated;
    lastError = null;
    notifyListeners();
    await loadCurrentTeacher();
  }

  Future<bool> refreshSession() {
    final activeRefresh = _refreshFuture;
    if (activeRefresh != null) {
      return activeRefresh;
    }
    final refresh = _performRefresh();
    _refreshFuture = refresh;
    return refresh.whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<bool> _performRefresh() async {
    final currentSession = session;
    if (currentSession == null) {
      return false;
    }
    status = AuthenticationStatus.refreshing;
    notifyListeners();
    try {
      final refreshed = await _authRepository.refresh(
        currentSession.refreshToken,
      );
      await _sessionStorage.saveSession(refreshed);
      session = refreshed;
      status = AuthenticationStatus.authenticated;
      lastError = null;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      lastError = error.message;
      await _clearLocalSession();
      return false;
    } catch (_) {
      await _clearLocalSession();
      return false;
    }
  }

  Future<String?> getValidAccessToken() async {
    final currentSession = session;
    if (currentSession == null) {
      return null;
    }
    if (currentSession.isExpiringSoon() && !await refreshSession()) {
      return null;
    }
    return session?.accessToken;
  }

  Future<void> loadCurrentTeacher() async {
    currentTeacher = await _teacherRepository.getMyProfile();
    lastError = null;
    notifyListeners();
  }

  Future<void> updateCurrentTeacher(UpdateTeacherProfileRequest request) async {
    currentTeacher = await _teacherRepository.updateMyProfile(request);
    lastError = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    final refreshToken = session?.refreshToken;
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authRepository.signOut(refreshToken);
      }
    } catch (_) {
      // Local session cleanup is mandatory even if the server is unreachable.
    } finally {
      await _clearLocalSession();
    }
  }

  Future<void> invalidateSession() => _clearLocalSession();

  Future<void> _clearLocalSession() async {
    await _sessionStorage.clearSession();
    session = null;
    currentTeacher = null;
    status = AuthenticationStatus.unauthenticated;
    notifyListeners();
  }
}
