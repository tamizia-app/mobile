import '../../../../core/network/api_exception.dart';
import '../../domain/models/create_student_request.dart';
import '../../domain/models/student.dart';
import '../../domain/models/student_consent.dart';
import '../../domain/models/update_student_request.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/create_student_request_dto.dart';
import '../models/update_student_request_dto.dart';

class StudentRepositoryImpl implements StudentRepository {
  const StudentRepositoryImpl({
    required StudentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StudentRemoteDataSource _remoteDataSource;

  @override
  Future<List<Student>> getStudentsByClassroom(String classroomId) async {
    final response = await _remoteDataSource.getStudentsByClassroom(
      classroomId,
    );
    return response.map((item) => item.toDomain()).toList(growable: false);
  }

  @override
  Future<Student> createStudent(
    String classroomId,
    CreateStudentRequest request,
  ) async {
    final response = await _remoteDataSource.createStudent(
      classroomId,
      CreateStudentRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }

  @override
  Future<Student> getStudentById(String studentId) async {
    final response = await _remoteDataSource.getStudentById(studentId);
    return response.toDomain();
  }

  @override
  Future<Student> updateStudent(
    String studentId,
    UpdateStudentRequest request,
  ) async {
    final response = await _remoteDataSource.updateStudent(
      studentId,
      UpdateStudentRequestDto.fromDomain(request),
    );
    return response.toDomain();
  }

  @override
  Future<void> deleteStudent(String studentId) {
    return _remoteDataSource.deleteStudent(studentId);
  }

  @override
  Future<StudentConsent?> getConsent(String studentId) async {
    try {
      final response = await _remoteDataSource.getConsent(studentId);
      return response.toDomain();
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<StudentConsent> revokeConsent(String studentId) async {
    final response = await _remoteDataSource.revokeConsent(studentId);
    return response.toDomain();
  }

  @override
  Future<StudentConsent> uploadConsent(
    String studentId, {
    required List<int> bytes,
    required String fileName,
  }) async {
    final response = await _remoteDataSource.uploadConsent(
      studentId,
      bytes: bytes,
      fileName: fileName,
    );
    return response.toDomain();
  }

  @override
  Future<Uri> getConsentTemplateDownloadUrl() async {
    final response = await _remoteDataSource.getConsentTemplateDownloadUrl();
    return response.downloadUrl;
  }

  @override
  Future<Uri> getConsentDownloadUrl(String studentId) async {
    final response = await _remoteDataSource.getConsentDownloadUrl(studentId);
    return response.downloadUrl;
  }
}
