import '../models/create_student_request.dart';
import '../models/student.dart';
import '../models/student_consent.dart';
import '../models/update_student_request.dart';

abstract interface class StudentRepository {
  Future<List<Student>> getAllStudents();

  Future<List<Student>> getStudentsByClassroom(String classroomId);

  Future<Student> createStudent(
    String classroomId,
    CreateStudentRequest request,
  );

  Future<Student> getStudentById(String studentId);

  Future<Student> updateStudent(String studentId, UpdateStudentRequest request);

  Future<void> deleteStudent(String studentId);

  Future<StudentConsent?> getConsent(String studentId);

  Future<StudentConsent> revokeConsent(String studentId);

  Future<StudentConsent> uploadConsent(
    String studentId, {
    required List<int> bytes,
    required String fileName,
  });

  Future<Uri> getConsentTemplateDownloadUrl();

  Future<Uri> getConsentDownloadUrl(String studentId);
}
