import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/teacher_profile.dart';
import 'teacher_service.dart';

class MockTeacherService implements TeacherService {
  TeacherProfile _profile = const TeacherProfile(
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan.perez@email.com',
    institution: 'Institución Educativa XYZ',
  );

  @override
  Future<TeacherProfile> getTeacherProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const DashboardSummary(
      classrooms: 12,
      students: 145,
      evaluations: 89,
      suggestedReviews: 5,
    );
  }

  @override
  Future<void> updateTeacherProfile(TeacherProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _profile = profile;
  }
}

// TODO: future backend integration.
// class ApiTeacherService implements TeacherService {
//   // GET /api/teacher/profile
//   // GET /api/teacher/dashboard
//   // PUT /api/teacher/profile
// }
