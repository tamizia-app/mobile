import '../models/classroom_dto.dart';
import '../models/create_classroom_request_dto.dart';
import '../models/update_classroom_request_dto.dart';

abstract interface class ClassroomRemoteDataSource {
  Future<List<ClassroomDto>> getClassrooms();

  Future<ClassroomDto> getClassroomById(String classroomId);

  Future<ClassroomDto> createClassroom(CreateClassroomRequestDto request);

  Future<ClassroomDto> updateClassroom(
    String classroomId,
    UpdateClassroomRequestDto request,
  );

  Future<void> deleteClassroom(String classroomId);
}
