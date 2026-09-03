import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
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
          AppHeader(title: 'Estudiantes', centerTitle: true),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            const SizedBox(height: 16),
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
      return const Center(
        child: Text(
          'No hay estudiantes registrados.',
          style: TextStyle(color: AppColors.mutedText, fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = responsiveColumnCount(
            constraints.maxWidth,
            tablet: 2,
            desktop: 2,
          );
          if (columns == 1) {
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              itemCount: students.length,
              itemBuilder: (context, index) =>
                  _buildStudentCard(context, students[index]),
            );
          }
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 126,
            ),
            itemCount: students.length,
            itemBuilder: (context, index) =>
                _buildStudentCard(context, students[index]),
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    return _StudentCard(
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

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.classroomName,
    required this.onTap,
  });

  final Student student;
  final String? classroomName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.age} años · ${translateGender(student.gender)}',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                    if (classroomName != null)
                      Text(
                        'Aula: $classroomName',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: student.isActive
                          ? AppColors.successGreen.withValues(alpha: 0.12)
                          : AppColors.mutedText.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      student.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: student.isActive
                            ? AppColors.successGreen
                            : AppColors.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: AppColors.mutedText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
