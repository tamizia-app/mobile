import '../../domain/models/classroom.dart';
import 'classroom_service.dart';

class MockClassroomService implements ClassroomService {
  final List<Classroom> _classrooms = [
    const Classroom(
      id: 'classroom-3b',
      name: '3ro B',
      grade: '3ro',
      section: 'B',
      schoolYear: '2026',
      studentCount: 24,
    ),
    const Classroom(
      id: 'classroom-4a',
      name: '4to A',
      grade: '4to',
      section: 'A',
      schoolYear: '2026',
      studentCount: 28,
    ),
    const Classroom(
      id: 'classroom-5c',
      name: '5to C',
      grade: '5to',
      section: 'C',
      schoolYear: '2026',
      studentCount: 21,
    ),
  ];

  @override
  Future<List<Classroom>> getClassrooms() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<Classroom>.unmodifiable(_classrooms);
  }

  @override
  Future<Classroom> getClassroomById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _classrooms.firstWhere(
      (classroom) => classroom.id == id,
      orElse: () => _classrooms.first,
    );
  }

  @override
  Future<void> createClassroom(Classroom classroom) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _classrooms.add(classroom);
  }

  @override
  Future<void> updateClassroom(Classroom classroom) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _classrooms.indexWhere((item) => item.id == classroom.id);
    if (index != -1) {
      _classrooms[index] = classroom;
    }
  }
}

// TODO: future backend integration.
// class ApiClassroomService implements ClassroomService {
//   // GET /api/classrooms
//   // GET /api/classrooms/{id}
//   // POST /api/classrooms
//   // PUT /api/classrooms/{id}
// }
