import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/student_card.dart';
import '../../../students/data/services/student_service.dart';
import '../../data/services/classroom_service.dart';
import '../viewmodels/classroom_detail_viewmodel.dart';

class ClassroomDetailPage extends StatefulWidget {
  const ClassroomDetailPage({
    required this.classroomService,
    required this.studentService,
    super.key,
  });

  final ClassroomService classroomService;
  final StudentService studentService;

  @override
  State<ClassroomDetailPage> createState() => _ClassroomDetailPageState();
}

class _ClassroomDetailPageState extends State<ClassroomDetailPage> {
  late final ClassroomDetailViewModel _viewModel;
  String _classroomId = 'classroom-3b';

  @override
  void initState() {
    super.initState();
    _viewModel = ClassroomDetailViewModel(
      classroomService: widget.classroomService,
      studentService: widget.studentService,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) {
      _classroomId = argument;
    }
    if (_viewModel.classroom == null) {
      _viewModel.load(_classroomId);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final classroom = _viewModel.classroom;
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: const AppBottomNav(
            currentItem: BottomNavItem.classrooms,
          ),
          body: Column(
            children: [
              AppHeader(
                title: classroom?.name ?? '3ro B',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.classrooms,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _notImplemented(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                fixedSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: const Text(
                                'Iniciar\nevaluación',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.createStudent,
                                arguments: classroom?.id ?? _classroomId,
                              ),
                              style: OutlinedButton.styleFrom(
                                fixedSize: const Size.fromHeight(48),
                                foregroundColor: const Color(0xFF102532),
                                side: const BorderSide(
                                  color: Color(0xFFB9C3D0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: const Text(
                                'Agregar\nestudiante',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editClassroom,
                            arguments: classroom?.id ?? _classroomId,
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar aula'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._viewModel.students.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: StudentCard(
                            student: student,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.studentDetail,
                              arguments: student.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No implementado todavía')));
  }
}
