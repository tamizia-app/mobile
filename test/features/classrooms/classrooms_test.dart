import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizai_app/core/network/api_client.dart';
import 'package:tamizai_app/core/network/api_error_mapper.dart';
import 'package:tamizai_app/core/network/api_exception.dart';
import 'package:tamizai_app/features/classrooms/data/datasources/classroom_remote_data_source.dart';
import 'package:tamizai_app/features/classrooms/data/datasources/classroom_remote_data_source_impl.dart';
import 'package:tamizai_app/features/classrooms/data/models/classroom_dto.dart';
import 'package:tamizai_app/features/classrooms/data/models/create_classroom_request_dto.dart';
import 'package:tamizai_app/features/classrooms/data/models/update_classroom_request_dto.dart';
import 'package:tamizai_app/features/classrooms/data/repositories/classroom_repository_impl.dart';
import 'package:tamizai_app/features/classrooms/domain/models/classroom.dart';
import 'package:tamizai_app/features/classrooms/domain/models/create_classroom_request.dart';
import 'package:tamizai_app/features/classrooms/domain/models/update_classroom_request.dart';
import 'package:tamizai_app/features/classrooms/domain/repositories/classroom_repository.dart';
import 'package:tamizai_app/features/classrooms/presentation/viewmodels/classroom_detail_viewmodel.dart';
import 'package:tamizai_app/features/classrooms/presentation/viewmodels/classroom_form_viewmodel.dart';
import 'package:tamizai_app/features/classrooms/presentation/viewmodels/classrooms_viewmodel.dart';

void main() {
  group('Classroom DTOs', () {
    test('maps snake_case and parses school_year as DateTime', () {
      final classroom = ClassroomDto.fromJson(_classroomJson()).toDomain();

      expect(classroom.classroomId, 'classroom-id');
      expect(classroom.homeroomTeacherId, 'teacher-id');
      expect(classroom.gradeLevel, 'tercero');
      expect(classroom.schoolYear, DateTime(2026, 6, 28));
    });

    test('rejects invalid or incomplete responses', () {
      final invalid = _classroomJson()..['school_year'] = '2026';
      expect(
        () => ClassroomDto.fromJson(invalid),
        throwsA(isA<FormatException>()),
      );

      final missing = _classroomJson()..remove('classroom_id');
      expect(
        () => ClassroomDto.fromJson(missing),
        throwsA(isA<FormatException>()),
      );
    });

    test('request DTOs send exactly the documented fields and ISO date', () {
      final create = CreateClassroomRequest(
        name: '3ro A',
        gradeLevel: 'tercero',
        section: 'A',
        schoolYear: _schoolYear,
      );
      final update = UpdateClassroomRequest(
        name: '4to B',
        gradeLevel: 'cuarto',
        section: 'B',
        schoolYear: _schoolYear,
      );

      expect(CreateClassroomRequestDto.fromDomain(create).toJson(), {
        'name': '3ro A',
        'grade_level': 'tercero',
        'section': 'A',
        'school_year': '2026-01-01',
      });
      expect(UpdateClassroomRequestDto.fromDomain(update).toJson(), {
        'name': '4to B',
        'grade_level': 'cuarto',
        'section': 'B',
        'school_year': '2026-01-01',
      });
    });
  });

  group('ClassroomRepositoryImpl', () {
    test('maps list, detail, create, update, and delete', () async {
      final dataSource = _FakeDataSource();
      final repository = ClassroomRepositoryImpl(remoteDataSource: dataSource);

      expect(
        (await repository.getClassrooms()).single.classroomId,
        'classroom-id',
      );
      expect((await repository.getClassroomById('classroom-id')).name, '3ro A');
      expect(
        (await repository.createClassroom(
          CreateClassroomRequest(
            name: '3ro A',
            gradeLevel: 'tercero',
            section: 'A',
            schoolYear: _schoolYear,
          ),
        )).classroomId,
        'classroom-id',
      );
      expect(
        (await repository.updateClassroom(
          'classroom-id',
          UpdateClassroomRequest(
            name: '4to B',
            gradeLevel: 'cuarto',
            section: 'B',
            schoolYear: _schoolYear,
          ),
        )).name,
        '3ro A',
      );
      await repository.deleteClassroom('classroom-id');

      expect(dataSource.deletedIds, ['classroom-id']);
    });

    test('DELETE accepts 204 without parsing a body', () async {
      final client = ApiClient();
      final adapter = _NoContentAdapter();
      client.dio.httpClientAdapter = adapter;
      client.configureAuthentication(
        accessTokenProvider: () async => 'access-token',
        refreshSession: () async => true,
      );
      final dataSource = ClassroomRemoteDataSourceImpl(apiClient: client);

      await expectLater(dataSource.deleteClassroom('classroom-id'), completes);
      expect(adapter.authorization, 'Bearer access-token');
    });
  });

  group('Classroom errors', () {
    test('maps classroom 404 and 409 to friendly exceptions', () {
      final notFound = ApiErrorMapper.map(
        _dioError(404, {'detail': 'Classroom not found.'}),
      );
      final conflict = ApiErrorMapper.map(
        _dioError(409, {'detail': 'Classroom already exists.'}),
      );
      final validation = ApiErrorMapper.map(
        _dioError(422, {
          'detail': [
            {
              'loc': ['body', 'grade_level'],
              'msg': 'Invalid grade',
            },
          ],
        }),
      );

      expect(notFound, isA<NotFoundException>());
      expect(notFound.message, 'El aula no fue encontrada.');
      expect(conflict, isA<ConflictException>());
      expect(validation, isA<ValidationException>());
      expect(validation.fieldErrors['grade_level'], 'Invalid grade');
    });
  });

  group('ClassroomsViewModel', () {
    test('exposes loading, list, empty state, and errors', () async {
      final completer = Completer<List<Classroom>>();
      final repository = _FakeRepository()..listCompleter = completer;
      final viewModel = ClassroomsViewModel(classroomRepository: repository);

      final loading = viewModel.loadClassrooms();
      expect(viewModel.isLoading, isTrue);
      completer.complete([_classroom()]);
      await loading;
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.classrooms, hasLength(1));

      repository
        ..listCompleter = null
        ..classrooms = const [];
      await viewModel.loadClassrooms();
      expect(viewModel.classrooms, isEmpty);

      repository.listError = const NetworkException('offline');
      await viewModel.loadClassrooms();
      expect(viewModel.errorMessage, 'offline');
    });

    test('searches locally and synchronizes mutations', () async {
      final repository = _FakeRepository()
        ..classrooms = [
          _classroom(),
          _classroom(id: 'second', name: 'Quinto B', grade: 'quinto'),
        ];
      final viewModel = ClassroomsViewModel(classroomRepository: repository);
      await viewModel.loadClassrooms();

      viewModel.search('quinto');
      expect(viewModel.filteredClassrooms.single.classroomId, 'second');
      viewModel.clearSearch();
      expect(viewModel.filteredClassrooms, hasLength(2));

      final created = _classroom(id: 'created', name: 'Primero A');
      viewModel.addClassroom(created);
      expect(viewModel.classrooms.first.classroomId, 'created');
      final updated = _classroom(id: 'created', name: 'Primero B');
      viewModel.updateClassroomInList(updated);
      expect(viewModel.classrooms.first.name, 'Primero B');
      viewModel.removeClassroom('created');
      expect(
        viewModel.classrooms.any((item) => item.classroomId == 'created'),
        isFalse,
      );
    });
  });

  group('Classroom form and detail ViewModels', () {
    test('creates with normalized values', () async {
      final repository = _FakeRepository();
      final selectedYear = DateTime.now().year;
      final viewModel = ClassroomFormViewModel(classroomRepository: repository)
        ..setName('  3ro A  ')
        ..setGradeLevel('tercero')
        ..setSection('a')
        ..setSchoolYear(selectedYear);

      final created = await viewModel.create();

      expect(created, isNotNull);
      expect(repository.createdRequest?.name, '3ro A');
      expect(repository.createdRequest?.section, 'A');
      expect(repository.createdRequest?.schoolYear, DateTime(selectedYear));
    });

    test(
      'preloads edit, detects changes, and skips PUT without changes',
      () async {
        final repository = _FakeRepository();
        final viewModel = ClassroomFormViewModel(
          classroomRepository: repository,
        );
        await viewModel.loadClassroom('classroom-id');

        expect(viewModel.name, '3ro A');
        expect(viewModel.schoolYear, DateTime(2026));
        expect(viewModel.hasChanges, isFalse);
        expect(viewModel.canSave, isFalse);
        expect(await viewModel.update(), isNull);
        expect(repository.updateCalls, 0);

        viewModel.setName('4to A');
        expect(viewModel.hasChanges, isTrue);
        expect(viewModel.canSave, isTrue);
        expect(await viewModel.update(), isNotNull);
        expect(repository.updateCalls, 1);
        expect(repository.updatedRequest?.schoolYear, DateTime(2026));
        expect(viewModel.hasChanges, isFalse);
      },
    );

    test('loads and deletes classroom', () async {
      final repository = _FakeRepository();
      final viewModel = ClassroomDetailViewModel(
        classroomRepository: repository,
      );

      await viewModel.loadClassroom('classroom-id');
      expect(viewModel.classroom?.name, '3ro A');
      expect(await viewModel.deleteClassroom(), isTrue);
      expect(repository.deletedIds, ['classroom-id']);
    });
  });
}

final _schoolYear = DateTime(2026, 6, 28);

Map<String, dynamic> _classroomJson() {
  return {
    'classroom_id': 'classroom-id',
    'homeroom_teacher_id': 'teacher-id',
    'name': '3ro A',
    'grade_level': 'tercero',
    'section': 'A',
    'school_year': '2026-06-28',
  };
}

Classroom _classroom({
  String id = 'classroom-id',
  String name = '3ro A',
  String grade = 'tercero',
}) {
  return Classroom(
    classroomId: id,
    homeroomTeacherId: 'teacher-id',
    name: name,
    gradeLevel: grade,
    section: 'A',
    schoolYear: _schoolYear,
  );
}

DioException _dioError(int statusCode, Map<String, dynamic> data) {
  final request = RequestOptions(path: '/api/v1/classrooms/classroom-id');
  return DioException(
    requestOptions: request,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: statusCode,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}

class _FakeDataSource implements ClassroomRemoteDataSource {
  final List<String> deletedIds = [];

  @override
  Future<List<ClassroomDto>> getClassrooms() async => [_dto()];

  @override
  Future<ClassroomDto> getClassroomById(String classroomId) async => _dto();

  @override
  Future<ClassroomDto> createClassroom(
    CreateClassroomRequestDto request,
  ) async => _dto();

  @override
  Future<ClassroomDto> updateClassroom(
    String classroomId,
    UpdateClassroomRequestDto request,
  ) async => _dto();

  @override
  Future<void> deleteClassroom(String classroomId) async {
    deletedIds.add(classroomId);
  }

  ClassroomDto _dto() => ClassroomDto.fromJson(_classroomJson());
}

class _FakeRepository implements ClassroomRepository {
  List<Classroom> classrooms = [_classroom()];
  Completer<List<Classroom>>? listCompleter;
  ApiException? listError;
  CreateClassroomRequest? createdRequest;
  UpdateClassroomRequest? updatedRequest;
  int updateCalls = 0;
  final List<String> deletedIds = [];

  @override
  Future<List<Classroom>> getClassrooms() {
    final error = listError;
    if (error != null) {
      throw error;
    }
    return listCompleter?.future ?? Future.value(classrooms);
  }

  @override
  Future<Classroom> getClassroomById(String classroomId) async {
    return classrooms.first;
  }

  @override
  Future<Classroom> createClassroom(CreateClassroomRequest request) async {
    createdRequest = request;
    final created = _classroom(name: request.name, grade: request.gradeLevel);
    classrooms = [created, ...classrooms];
    return created;
  }

  @override
  Future<Classroom> updateClassroom(
    String classroomId,
    UpdateClassroomRequest request,
  ) async {
    updateCalls++;
    updatedRequest = request;
    final updated = Classroom(
      classroomId: classroomId,
      homeroomTeacherId: 'teacher-id',
      name: request.name,
      gradeLevel: request.gradeLevel,
      section: request.section,
      schoolYear: request.schoolYear,
    );
    classrooms = [updated];
    return updated;
  }

  @override
  Future<void> deleteClassroom(String classroomId) async {
    deletedIds.add(classroomId);
  }
}

class _NoContentAdapter implements HttpClientAdapter {
  String? authorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorization = options.headers['Authorization'] as String?;
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}
