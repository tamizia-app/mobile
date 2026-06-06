import '../../domain/models/student.dart';
import 'student_service.dart';

class MockStudentService implements StudentService {
  final List<Student> _students = [
    const Student(
      id: 'student-001',
      code: 'COD-101',
      alias: 'Mateo R.',
      age: 15,
      grade: '3ro',
      classroomId: 'classroom-3b',
      classroomName: 'Aula A',
      lastEvaluation: '10/10/2023',
      consentStatus: 'Aprobado',
      revisionLevel: 'Nivel 3 - Avanzado',
      hasParentAuthorization: true,
    ),
    const Student(
      id: 'student-002',
      code: 'COD-102',
      alias: 'Valeria M.',
      age: 16,
      grade: '3ro',
      classroomId: 'classroom-3b',
      classroomName: 'Aula A',
      lastEvaluation: '05/10/2023',
      consentStatus: 'Aprobado',
      revisionLevel: 'Nivel 2 - En progreso',
      hasParentAuthorization: true,
    ),
    const Student(
      id: 'student-003',
      code: 'COD-103',
      alias: 'Diego P.',
      age: 15,
      grade: '3ro',
      classroomId: 'classroom-3b',
      classroomName: 'Aula A',
      lastEvaluation: 'N/A',
      consentStatus: 'Pendiente',
      revisionLevel: 'Sin evaluación',
      needsReview: true,
    ),
    const Student(
      id: 'student-detail',
      code: 'COD-342',
      alias: 'EST-001',
      age: 11,
      grade: 'Grado 5',
      classroomId: 'classroom-5c',
      classroomName: 'Aula A',
      lastEvaluation: '10/10/2023',
      consentStatus: 'Aprobado',
      revisionLevel: 'Nivel 3 - Avanzado',
      hasParentAuthorization: true,
    ),
  ];

  @override
  Future<List<Student>> getStudentsByClassroom(String classroomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final students = _students
        .where((student) => student.classroomId == classroomId)
        .toList();
    return List<Student>.unmodifiable(
      students.isEmpty ? _students.take(3).toList() : students,
    );
  }

  @override
  Future<Student> getStudentById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _students.firstWhere(
      (student) => student.id == id,
      orElse: () => _students.first,
    );
  }

  @override
  Future<void> createStudent(Student student) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _students.add(student);
  }

  @override
  Future<void> updateStudent(Student student) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _students.indexWhere((item) => item.id == student.id);
    if (index != -1) {
      _students[index] = student;
    }
  }
}

// TODO: future backend integration.
// class ApiStudentService implements StudentService {
//   // GET /api/classrooms/{classroomId}/students
//   // GET /api/students/{id}
//   // POST /api/students
//   // PUT /api/students/{id}
// }
