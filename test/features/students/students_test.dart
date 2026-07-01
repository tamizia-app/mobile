import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/network/api_client.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/features/students/data/datasources/student_remote_data_source.dart';
import 'package:tamizai_app/features/students/data/datasources/student_remote_data_source_impl.dart';
import 'package:tamizai_app/features/students/data/models/create_student_request_dto.dart';
import 'package:tamizai_app/features/students/data/models/download_url_dto.dart';
import 'package:tamizai_app/features/students/data/models/student_consent_dto.dart';
import 'package:tamizai_app/features/students/data/models/student_dto.dart';
import 'package:tamizai_app/features/students/data/models/update_student_request_dto.dart';
import 'package:tamizai_app/features/students/data/repositories/student_repository_impl.dart';
import 'package:tamizai_app/features/students/domain/models/create_student_request.dart';
import 'package:tamizai_app/features/students/domain/models/student.dart';
import 'package:tamizai_app/features/students/domain/models/student_consent.dart';
import 'package:tamizai_app/features/students/domain/models/update_student_request.dart';
import 'package:tamizai_app/features/students/domain/repositories/student_repository.dart';
import 'package:tamizai_app/features/students/presentation/viewmodels/student_detail_viewmodel.dart';
import 'package:tamizai_app/features/students/presentation/viewmodels/student_form_viewmodel.dart';
import 'package:tamizai_app/features/students/presentation/viewmodels/students_by_classroom_viewmodel.dart';

void main() {
  group('Student DTOs', () {
    test('parses student snake_case fields and ISO dates', () {
      final student = StudentDto.fromJson(_studentJson()).toDomain();

      expect(student.studentId, 'student-id');
      expect(student.classroomId, 'classroom-id');
      expect(student.code, 'EST-001');
      expect(student.age, 10);
      expect(student.gender, 'BOY');
      expect(student.isActive, isTrue);
      expect(student.createdAt, DateTime.parse(_createdAt));
    });

    test('parses nullable consent dates', () {
      final consent = StudentConsentDto.fromJson(
        _consentJson(revokedAt: null),
      ).toDomain();

      expect(consent.consentId, 'consent-id');
      expect(consent.status, isTrue);
      expect(consent.revokedAt, isNull);
      expect(consent.evidenceBlobPath, 'path/consent.pdf');
    });

    test('request DTOs contain only code, age, and gender', () {
      const create = CreateStudentRequest(
        code: 'EST-001',
        age: 10,
        gender: 'BOY',
      );
      const update = UpdateStudentRequest(
        code: 'EST-002',
        age: 11,
        gender: 'GIRL',
      );

      expect(CreateStudentRequestDto.fromDomain(create).toJson(), {
        'code': 'EST-001',
        'age': 10,
        'gender': 'BOY',
      });
      expect(UpdateStudentRequestDto.fromDomain(update).toJson(), {
        'code': 'EST-002',
        'age': 11,
        'gender': 'GIRL',
      });
    });

    test('parses observed download_url response', () {
      final dto = DownloadUrlDto.fromJson({
        'download_url': 'https://example.com/consent.pdf',
      });
      expect(dto.downloadUrl.host, 'example.com');
    });
  });

  group('StudentRepositoryImpl', () {
    test('maps CRUD, consent, upload, and download URLs', () async {
      final dataSource = _FakeDataSource();
      final repository = StudentRepositoryImpl(remoteDataSource: dataSource);

      expect(
        (await repository.getStudentsByClassroom('classroom-id')).single.code,
        'EST-001',
      );
      expect(
        (await repository.createStudent(
          'classroom-id',
          const CreateStudentRequest(code: 'EST-001', age: 10, gender: 'BOY'),
        )).studentId,
        'student-id',
      );
      expect((await repository.getStudentById('student-id')).age, 10);
      expect(
        (await repository.updateStudent(
          'student-id',
          const UpdateStudentRequest(code: 'EST-002', age: 11, gender: 'GIRL'),
        )).gender,
        'BOY',
      );
      expect((await repository.getConsent('student-id'))?.status, isTrue);
      expect(
        (await repository.revokeConsent('student-id')).studentId,
        'student-id',
      );
      expect(
        (await repository.uploadConsent(
          'student-id',
          bytes: [1, 2, 3],
          fileName: 'consent.pdf',
        )).consentId,
        'consent-id',
      );
      expect(
        (await repository.getConsentTemplateDownloadUrl()).host,
        'example.com',
      );
      expect(
        (await repository.getConsentDownloadUrl('student-id')).path,
        '/consent.pdf',
      );
      await repository.deleteStudent('student-id');
      expect(dataSource.deletedIds, ['student-id']);
    });

    test('maps missing consent to null', () async {
      final repository = StudentRepositoryImpl(
        remoteDataSource: _FakeDataSource()..consentMissing = true,
      );
      expect(await repository.getConsent('student-id'), isNull);
    });

    test('DELETE handles 204 and upload uses multipart file field', () async {
      final client = ApiClient();
      final adapter = _StudentAdapter();
      client.dio.httpClientAdapter = adapter;
      client.configureAuthentication(
        accessTokenProvider: () async => 'access-token',
        refreshSession: () async => true,
      );
      final dataSource = StudentRemoteDataSourceImpl(apiClient: client);

      await expectLater(dataSource.deleteStudent('student-id'), completes);
      final uploaded = await dataSource.uploadConsent(
        'student-id',
        bytes: [1, 2, 3],
        fileName: 'consent.pdf',
      );

      expect(uploaded.studentId, 'student-id');
      expect(adapter.authorizationHeaders, everyElement('Bearer access-token'));
      expect(adapter.uploadWasMultipart, isTrue);
    });
  });

  group('StudentsByClassroomViewModel', () {
    test('handles loading, empty, error, and local search', () async {
      final completer = Completer<List<Student>>();
      final repository = _FakeRepository()..listCompleter = completer;
      final viewModel = StudentsByClassroomViewModel(
        studentRepository: repository,
      );

      final loading = viewModel.loadStudents('classroom-id');
      expect(viewModel.isLoading, isTrue);
      completer.complete([_student(), _student(id: 'second', code: 'ABC-2')]);
      await loading;
      expect(viewModel.students, hasLength(2));
      expect(repository.listClassroomIds, ['classroom-id']);

      viewModel.search('abc');
      expect(viewModel.filteredStudents.single.studentId, 'second');

      repository
        ..listCompleter = null
        ..students = const [];
      await viewModel.loadStudents('classroom-id');
      expect(viewModel.students, isEmpty);

      repository.listError = const NetworkException('offline');
      await viewModel.loadStudents('classroom-id');
      expect(viewModel.errorMessage, 'offline');
    });

    test('synchronizes create, update, and delete locally', () {
      final viewModel = StudentsByClassroomViewModel(
        studentRepository: _FakeRepository(),
      );
      final first = _student();
      viewModel.addStudent(first);
      viewModel.updateStudentInList(_student(code: 'UPDATED'));
      expect(viewModel.students.single.code, 'UPDATED');
      viewModel.removeStudent(first.studentId);
      expect(viewModel.students, isEmpty);
    });
  });

  group('Student form and detail ViewModels', () {
    test(
      'creates using the real classroom ID and normalized request',
      () async {
        final repository = _FakeRepository();
        final viewModel = StudentFormViewModel(studentRepository: repository)
          ..initializeForCreate('classroom-id')
          ..setCode('  EST-001  ')
          ..setAge('10')
          ..setGender('BOY');

        expect(await viewModel.createStudent(), isNotNull);
        expect(repository.createdClassroomId, 'classroom-id');
        expect(repository.createdRequest?.code, 'EST-001');
      },
    );

    test('creates without consent and does not call upload', () async {
      final repository = _FakeRepository();
      final viewModel = _validCreateViewModel(repository);

      final result = await viewModel.createStudentWithOptionalConsent();

      expect(result?.consentStatus, StudentConsentUploadStatus.notSelected);
      expect(repository.uploadCalls, 0);
      expect(repository.operationLog, ['create']);
    });

    test(
      'uploads selected consent after creating with returned student ID',
      () async {
        final repository = _FakeRepository();
        final viewModel = _validCreateViewModel(repository);
        expect(
          viewModel.selectConsentFile(name: 'consent.pdf', bytes: [1, 2, 3]),
          isTrue,
        );

        final result = await viewModel.createStudentWithOptionalConsent();

        expect(result?.consentStatus, StudentConsentUploadStatus.uploaded);
        expect(repository.uploadStudentIds, ['student-id']);
        expect(repository.operationLog, ['create', 'upload']);
      },
    );

    test('returns partial success when upload fails', () async {
      final repository = _FakeRepository()
        ..uploadError = const NetworkException('offline');
      final viewModel = _validCreateViewModel(repository)
        ..selectConsentFile(name: 'consent.png', bytes: [1]);

      final result = await viewModel.createStudentWithOptionalConsent();

      expect(result?.student.studentId, 'student-id');
      expect(result?.consentStatus, StudentConsentUploadStatus.pending);
      expect(result?.message, contains('fue registrado'));
    });

    test('preloads edit and skips PUT without changes', () async {
      final repository = _FakeRepository();
      final viewModel = StudentFormViewModel(studentRepository: repository);
      await viewModel.loadStudent('student-id');

      expect(viewModel.code, 'EST-001');
      expect(viewModel.age, '10');
      expect(viewModel.gender, 'BOY');
      expect(viewModel.hasChanges, isFalse);
      expect(await viewModel.updateStudent(), isNull);
      expect(repository.updateCalls, 0);

      viewModel.setGender('GIRL');
      expect(viewModel.canSave, isTrue);
      expect(await viewModel.updateStudent(), isNotNull);
      expect(repository.updateCalls, 1);
      expect(viewModel.hasChanges, isFalse);
    });

    test('loads consent, revokes, uploads, and deletes', () async {
      final repository = _FakeRepository();
      final viewModel = StudentDetailViewModel(studentRepository: repository);
      await viewModel.loadStudent('student-id');

      expect(viewModel.student?.studentId, 'student-id');
      expect(viewModel.consent?.status, isTrue);
      expect(await viewModel.revokeConsent(), isTrue);
      expect(
        await viewModel.uploadConsent(bytes: [1], fileName: 'c.pdf'),
        isTrue,
      );
      expect(await viewModel.deleteStudent(), isTrue);
      expect(repository.deletedIds, ['student-id']);
    });

    test('represents missing consent as pending state', () async {
      final repository = _FakeRepository()..consentValue = null;
      final viewModel = StudentDetailViewModel(studentRepository: repository);

      await viewModel.loadStudent('student-id');

      expect(viewModel.student, isNotNull);
      expect(viewModel.consent, isNull);
      expect(viewModel.errorMessage, isNull);
    });
  });
}

const _createdAt = '2026-06-29T00:59:20.627581Z';
const _updatedAt = '2026-06-29T00:59:20.779104Z';

Map<String, dynamic> _studentJson() {
  return {
    'student_id': 'student-id',
    'classroom_id': 'classroom-id',
    'code': 'EST-001',
    'age': 10,
    'gender': 'BOY',
    'is_active': true,
    'created_at': _createdAt,
    'updated_at': _updatedAt,
  };
}

Map<String, dynamic> _consentJson({String? revokedAt}) {
  return {
    'consent_id': 'consent-id',
    'student_id': 'student-id',
    'status': true,
    'consent_date': _createdAt,
    'revoked_at': revokedAt,
    'evidence_blob_path': 'path/consent.pdf',
    'created_at': _createdAt,
    'updated_at': _updatedAt,
  };
}

Student _student({
  String id = 'student-id',
  String code = 'EST-001',
  String gender = 'BOY',
}) {
  return Student(
    studentId: id,
    classroomId: 'classroom-id',
    code: code,
    age: 10,
    gender: gender,
    isActive: true,
    createdAt: DateTime.parse(_createdAt),
    updatedAt: DateTime.parse(_updatedAt),
  );
}

StudentConsent _consent() {
  return StudentConsentDto.fromJson(_consentJson()).toDomain();
}

StudentFormViewModel _validCreateViewModel(_FakeRepository repository) {
  return StudentFormViewModel(studentRepository: repository)
    ..initializeForCreate('classroom-id')
    ..setCode('EST-001')
    ..setAge('10')
    ..setGender('BOY');
}

class _FakeDataSource implements StudentRemoteDataSource {
  bool consentMissing = false;
  final List<String> deletedIds = [];

  @override
  Future<List<StudentDto>> getAllStudents() async {
    return [StudentDto.fromJson(_studentJson())];
  }

  @override
  Future<List<StudentDto>> getStudentsByClassroom(String classroomId) async {
    return [StudentDto.fromJson(_studentJson())];
  }

  @override
  Future<StudentDto> createStudent(
    String classroomId,
    CreateStudentRequestDto request,
  ) async => StudentDto.fromJson(_studentJson());

  @override
  Future<StudentDto> getStudentById(String studentId) async {
    return StudentDto.fromJson(_studentJson());
  }

  @override
  Future<StudentDto> updateStudent(
    String studentId,
    UpdateStudentRequestDto request,
  ) async => StudentDto.fromJson(_studentJson());

  @override
  Future<void> deleteStudent(String studentId) async {
    deletedIds.add(studentId);
  }

  @override
  Future<StudentConsentDto> getConsent(String studentId) async {
    if (consentMissing) {
      throw const NotFoundException('Consent not found');
    }
    return StudentConsentDto.fromJson(_consentJson());
  }

  @override
  Future<StudentConsentDto> revokeConsent(String studentId) async {
    return StudentConsentDto.fromJson(_consentJson(revokedAt: _updatedAt));
  }

  @override
  Future<StudentConsentDto> uploadConsent(
    String studentId, {
    required List<int> bytes,
    required String fileName,
  }) async => StudentConsentDto.fromJson(_consentJson());

  @override
  Future<DownloadUrlDto> getConsentTemplateDownloadUrl() async {
    return DownloadUrlDto(
      downloadUrl: Uri.https('example.com', '/template.pdf'),
    );
  }

  @override
  Future<DownloadUrlDto> getConsentDownloadUrl(String studentId) async {
    return DownloadUrlDto(
      downloadUrl: Uri.https('example.com', '/consent.pdf'),
    );
  }
}

class _FakeRepository implements StudentRepository {
  List<Student> students = [_student()];
  Completer<List<Student>>? listCompleter;
  ApiException? listError;
  final List<String> listClassroomIds = [];
  String? createdClassroomId;
  CreateStudentRequest? createdRequest;
  UpdateStudentRequest? updatedRequest;
  int updateCalls = 0;
  int uploadCalls = 0;
  ApiException? uploadError;
  StudentConsent? consentValue = _consent();
  final List<String> uploadStudentIds = [];
  final List<String> operationLog = [];
  final List<String> deletedIds = [];

  @override
  Future<List<Student>> getAllStudents() async => students;

  @override
  Future<List<Student>> getStudentsByClassroom(String classroomId) {
    listClassroomIds.add(classroomId);
    final error = listError;
    if (error != null) {
      throw error;
    }
    return listCompleter?.future ?? Future.value(students);
  }

  @override
  Future<Student> createStudent(
    String classroomId,
    CreateStudentRequest request,
  ) async {
    operationLog.add('create');
    createdClassroomId = classroomId;
    createdRequest = request;
    return _student(code: request.code, gender: request.gender);
  }

  @override
  Future<Student> getStudentById(String studentId) async => _student();

  @override
  Future<Student> updateStudent(
    String studentId,
    UpdateStudentRequest request,
  ) async {
    updateCalls++;
    updatedRequest = request;
    return _student(code: request.code, gender: request.gender);
  }

  @override
  Future<void> deleteStudent(String studentId) async {
    deletedIds.add(studentId);
  }

  @override
  Future<StudentConsent?> getConsent(String studentId) async => consentValue;

  @override
  Future<StudentConsent> revokeConsent(String studentId) async => _consent();

  @override
  Future<StudentConsent> uploadConsent(
    String studentId, {
    required List<int> bytes,
    required String fileName,
  }) async {
    uploadCalls++;
    uploadStudentIds.add(studentId);
    operationLog.add('upload');
    final error = uploadError;
    if (error != null) {
      throw error;
    }
    return _consent();
  }

  @override
  Future<Uri> getConsentTemplateDownloadUrl() async {
    return Uri.https('example.com', '/template.pdf');
  }

  @override
  Future<Uri> getConsentDownloadUrl(String studentId) async {
    return Uri.https('example.com', '/consent.pdf');
  }
}

class _StudentAdapter implements HttpClientAdapter {
  final List<String?> authorizationHeaders = [];
  bool uploadWasMultipart = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    if (options.path.endsWith('/consent/upload')) {
      uploadWasMultipart =
          options.headers[Headers.contentTypeHeader]?.toString().startsWith(
            'multipart/form-data',
          ) ??
          false;
      return ResponseBody.fromString(
        _jsonEncode(_consentJson()),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}

String _jsonEncode(Map<String, dynamic> json) {
  return '{"consent_id":"${json['consent_id']}",'
      '"student_id":"${json['student_id']}",'
      '"status":true,'
      '"consent_date":"${json['consent_date']}",'
      '"revoked_at":null,'
      '"evidence_blob_path":"${json['evidence_blob_path']}",'
      '"created_at":"${json['created_at']}",'
      '"updated_at":"${json['updated_at']}"}';
}
