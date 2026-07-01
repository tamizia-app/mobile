import '../models/create_student_request_dto.dart';
import '../models/download_url_dto.dart';
import '../models/student_consent_dto.dart';
import '../models/student_dto.dart';
import '../models/update_student_request_dto.dart';

abstract interface class StudentRemoteDataSource {
  Future<List<StudentDto>> getAllStudents();

  Future<List<StudentDto>> getStudentsByClassroom(String classroomId);

  Future<StudentDto> createStudent(
    String classroomId,
    CreateStudentRequestDto request,
  );

  Future<StudentDto> getStudentById(String studentId);

  Future<StudentDto> updateStudent(
    String studentId,
    UpdateStudentRequestDto request,
  );

  Future<void> deleteStudent(String studentId);

  Future<StudentConsentDto> getConsent(String studentId);

  Future<StudentConsentDto> revokeConsent(String studentId);

  Future<StudentConsentDto> uploadConsent(
    String studentId, {
    required List<int> bytes,
    required String fileName,
  });

  Future<DownloadUrlDto> getConsentTemplateDownloadUrl();

  Future<DownloadUrlDto> getConsentDownloadUrl(String studentId);
}
