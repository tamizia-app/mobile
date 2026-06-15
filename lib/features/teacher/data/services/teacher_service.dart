import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/teacher_profile.dart';

abstract class TeacherService {
  Future<TeacherProfile> getTeacherProfile();

  Future<DashboardSummary> getDashboardSummary();

  Future<void> updateTeacherProfile(TeacherProfile profile);
}
