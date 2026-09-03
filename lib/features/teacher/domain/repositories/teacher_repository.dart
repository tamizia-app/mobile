import '../models/teacher_profile.dart';
import '../models/update_teacher_profile_request.dart';

abstract interface class TeacherRepository {
  Future<TeacherProfile> getMyProfile();

  Future<TeacherProfile> updateMyProfile(UpdateTeacherProfileRequest request);
}
