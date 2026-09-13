import '../models/classroom.dart';
import '../models/create_classroom_request.dart';
import '../models/update_classroom_request.dart';

abstract interface class ClassroomRepository {
  Future<List<Classroom>> getClassrooms();

  Future<Classroom> getClassroomById(String classroomId);

  Future<Classroom> createClassroom(CreateClassroomRequest request);

  Future<Classroom> updateClassroom(
    String classroomId,
    UpdateClassroomRequest request,
  );

  Future<void> deleteClassroom(String classroomId);
}
