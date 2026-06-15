import '../../domain/models/student.dart';

abstract class StudentService {
  Future<List<Student>> getStudentsByClassroom(String classroomId);

  Future<Student> getStudentById(String id);

  Future<void> createStudent(Student student);

  Future<void> updateStudent(Student student);
}
