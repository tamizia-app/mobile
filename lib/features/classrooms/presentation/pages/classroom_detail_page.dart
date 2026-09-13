import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/student_card.dart';
import '../../../students/domain/models/student.dart';
import '../../../students/domain/repositories/student_repository.dart';
import '../../../students/presentation/viewmodels/student_form_viewmodel.dart';
import '../../../students/presentation/viewmodels/students_by_classroom_viewmodel.dart';
import '../../domain/models/classroom.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../viewmodels/classroom_detail_viewmodel.dart';

class ClassroomDetailPage extends StatefulWidget {
  const ClassroomDetailPage({
    required this.classroomRepository,
    required this.studentRepository,
    super.key,
  });

  final ClassroomRepository classroomRepository;
  final StudentRepository studentRepository;

  @override
  State<ClassroomDetailPage> createState() => _ClassroomDetailPageState();
}

class _ClassroomDetailPageState extends State<ClassroomDetailPage> {
  late final ClassroomDetailViewModel _classroomViewModel;
  late final StudentsByClassroomViewModel _studentsViewModel;
  late final Listenable _animation;
  String? _classroomId;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _classroomViewModel = ClassroomDetailViewModel(
      classroomRepository: widget.classroomRepository,
    );
    _studentsViewModel = StudentsByClassroomViewModel(
      studentRepository: widget.studentRepository,
    );
    _animation = Listenable.merge([_classroomViewModel, _studentsViewModel]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String && argument.isNotEmpty) {
      _classroomId = argument;
    }
    if (!_requestedLoad && _classroomId != null) {
      _requestedLoad = true;
      _classroomViewModel.loadClassroom(_classroomId!);
      _studentsViewModel.loadStudents(_classroomId!);
    }
  }

  @override
  void dispose() {
    _classroomViewModel.dispose();
    _studentsViewModel.dispose();
    super.dispose();
  }

  Future<void> _editClassroom() async {
    final classroom = _classroomViewModel.classroom;
    if (classroom == null) {
      return;
    }
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.editClassroom,
      arguments: classroom.classroomId,
    );
    if (!mounted || updated is! Classroom) {
      return;
    }
    _classroomViewModel.applyUpdate(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aula actualizada correctamente.')),
    );
  }

  Future<void> _registerStudent() async {
    final classroom = _classroomViewModel.classroom;
    if (classroom == null) {
      return;
    }
    final created = await Navigator.pushNamed(
      context,
      AppRoutes.createStudent,
      arguments: {
        'classroomId': classroom.classroomId,
        'classroomName': classroom.name,
      },
    );
    if (!mounted || created is! StudentCreationResult) {
      return;
    }
    _studentsViewModel.addStudent(created.student);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(created.message)));
  }

  Future<void> _openStudent(Student student) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.studentDetail,
      arguments: student.studentId,
    );
    if (!mounted) {
      return;
    }
    if (result is Student) {
      _studentsViewModel.updateStudentInList(result);
    } else if (result is String) {
      _studentsViewModel.removeStudent(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante eliminado correctamente.')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Eliminar aula?'),
          content: const Text(
            'Esta acción eliminará el aula. Verifica que no existan '
            'estudiantes o evaluaciones asociadas antes de continuar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
              child: const Text('Eliminar aula'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    final deleted = await _classroomViewModel.deleteClassroom();
    if (!mounted || !deleted) {
      return;
    }
    Navigator.pop(context, _classroomViewModel.classroom!.classroomId);
  }

  void _goBack() {
    Navigator.pop(context, _classroomViewModel.classroom);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final classroom = _classroomViewModel.classroom;
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: const AppBottomNav(
            currentItem: BottomNavItem.classrooms,
          ),
          body: Column(
            children: [
              AppHeader(
                title: classroom?.name ?? 'Detalle de aula',
                showBack: true,
                centerTitle: true,
                onBack: _goBack,
              ),
              Expanded(child: _buildContent(classroom)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(Classroom? classroom) {
    if (_classroomViewModel.isLoading) {
      return const AppLoadingState(message: 'Cargando información…');
    }
    if (classroom == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _classroomViewModel.errorMessage ?? 'No se pudo cargar el aula.',
            ),
            TextButton(
              onPressed: _classroomId == null
                  ? null
                  : () => _classroomViewModel.loadClassroom(_classroomId!),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _studentsViewModel.refreshStudents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ClassroomSummary(classroom: classroom),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: _editClassroom,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar aula'),
            ),
            const SizedBox(height: AppSpacing.sm),

            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Estudiantes (${_studentsViewModel.students.length})',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: _registerStudent,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Registrar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._buildStudents(),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: _classroomViewModel.isDeleting ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(
                _classroomViewModel.isDeleting
                    ? 'Eliminando...'
                    : 'Eliminar aula',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStudents() {
    if (_studentsViewModel.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: AppLoadingState(message: 'Cargando estudiantes…'),
        ),
      ];
    }
    if (_studentsViewModel.errorMessage != null &&
        _studentsViewModel.students.isEmpty) {
      return [
        Text(
          'No se pudieron cargar los estudiantes.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.errorRed),
        ),
        TextButton(
          onPressed: _studentsViewModel.refreshStudents,
          child: const Text('Reintentar'),
        ),
      ];
    }
    if (_studentsViewModel.students.isEmpty) {
      return [
        AppEmptyState(
          title: 'Aún no hay estudiantes',
          message: 'Registra al primer estudiante para comenzar.',
          icon: Icons.people_outline,
          actionLabel: 'Registrar estudiante',
          onAction: _registerStudent,
        ),
      ];
    }
    return _studentsViewModel.filteredStudents
        .map(
          (student) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: StudentCard(
              student: student,
              onTap: () => _openStudent(student),
            ),
          ),
        )
        .toList(growable: false);
  }
}

class _ClassroomSummary extends StatelessWidget {
  const _ClassroomSummary({required this.classroom});

  final Classroom classroom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Grado', value: _capitalize(classroom.gradeLevel)),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(label: 'Sección', value: classroom.section),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: 'Año escolar',
            value: '${classroom.schoolYear.year}',
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) =>
      AppDetailRow(label: label, value: value);
}
