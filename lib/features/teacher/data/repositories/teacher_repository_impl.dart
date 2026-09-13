import '../../domain/models/teacher_profile.dart';
import '../../domain/models/update_teacher_profile_request.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_data_source.dart';
import '../models/update_teacher_profile_request_dto.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  const TeacherRepositoryImpl({
    required TeacherRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TeacherRemoteDataSource _remoteDataSource;

  @override
  Future<TeacherProfile> getMyProfile() async {
    final response = await _remoteDataSource.getMyProfile();
    return response.toDomain();
  }

  @override
  Future<TeacherProfile> updateMyProfile(
    UpdateTeacherProfileRequest request,
  ) async {
    final response = await _remoteDataSource.updateMyProfile(
      UpdateTeacherProfileRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }
}
