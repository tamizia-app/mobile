import '../models/teacher_profile_dto.dart';
import '../models/update_teacher_profile_request_dto.dart';

abstract interface class TeacherRemoteDataSource {
  Future<TeacherProfileDto> getMyProfile();

  Future<TeacherProfileDto> updateMyProfile(
    UpdateTeacherProfileRequestDto request,
  );
}
