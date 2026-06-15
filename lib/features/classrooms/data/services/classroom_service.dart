import '../../domain/models/classroom.dart';

abstract class ClassroomService {
  Future<List<Classroom>> getClassrooms();

  Future<Classroom> getClassroomById(String id);

  Future<void> createClassroom(Classroom classroom);

  Future<void> updateClassroom(Classroom classroom);
}
