import '../../domain/models/classroom.dart';
import '../../domain/models/create_classroom_request.dart';
import '../../domain/models/update_classroom_request.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../datasources/classroom_remote_data_source.dart';
import '../models/create_classroom_request_dto.dart';
import '../models/update_classroom_request_dto.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  const ClassroomRepositoryImpl({
    required ClassroomRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ClassroomRemoteDataSource _remoteDataSource;

  @override
  Future<List<Classroom>> getClassrooms() async {
    final response = await _remoteDataSource.getClassrooms();
    return response.map((item) => item.toDomain()).toList(growable: false);
  }

  @override
  Future<Classroom> getClassroomById(String classroomId) async {
    final response = await _remoteDataSource.getClassroomById(classroomId);
    return response.toDomain();
  }

  @override
  Future<Classroom> createClassroom(CreateClassroomRequest request) async {
    final response = await _remoteDataSource.createClassroom(
      CreateClassroomRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }

  @override
  Future<Classroom> updateClassroom(
    String classroomId,
    UpdateClassroomRequest request,
  ) async {
    final response = await _remoteDataSource.updateClassroom(
      classroomId,
      UpdateClassroomRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }

  @override
  Future<void> deleteClassroom(String classroomId) {
    return _remoteDataSource.deleteClassroom(classroomId);
  }
}
