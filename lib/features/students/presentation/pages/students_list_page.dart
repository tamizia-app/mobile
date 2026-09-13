import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

import '../../../../core/widgets/app_states.dart';

import '../../../../core/widgets/student_card.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/app_header.dart';

import '../../domain/models/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../../../classrooms/domain/repositories/classroom_repository.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({
    required this.studentRepository,
    required this.classroomRepository,
    super.key,
  });

  final StudentRepository studentRepository;
  final ClassroomRepository classroomRepository;

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  List<Student>? _students;
  Map<String, String> _classroomNames = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        widget.studentRepository.getAllStudents(),
        widget.classroomRepository.getClassrooms(),
      ]);
      final students = results[0] as List<Student>;
      final classrooms = results[1] as List;
      final names = <String, String>{};
      for (final c in classrooms) {
        final id = c.classroomId as String;
        final name = c.name as String;
        final grade = c.gradeLevel as String;
        final section = c.section as String;
        names[id] = '$name - $grade $section';
      }
      setState(() {
        _students = students;
        _classroomNames = names;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los estudiantes.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(title: 'Estudiantes', showBack: true),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Cargando información…');
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.errorRed),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    final students = _students!;
    if (students.isEmpty) {
      return AppEmptyState(
        title: 'Aún no hay estudiantes',
        message: 'Entra a un aula para registrar al primer estudiante.',
        icon: Icons.people_outline,
        actionLabel: 'Ver aulas',
        onAction: () => Navigator.pushNamed(context, AppRoutes.classrooms),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.page,
        children: [
          AppAdaptiveCollection(
            children: [
              for (final student in students)
                _buildStudentCard(context, student),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    return StudentCard(
      student: student,
      classroomName: _classroomNames[student.classroomId],
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.studentDetail,
        arguments: student.studentId,
      ),
    );
  }
}
