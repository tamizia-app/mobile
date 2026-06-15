import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../data/services/student_service.dart';
import '../viewmodels/student_detail_viewmodel.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({required this.studentService, super.key});

  final StudentService studentService;

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late final StudentDetailViewModel _viewModel;
  String _studentId = 'student-detail';

  @override
  void initState() {
    super.initState();
    _viewModel = StudentDetailViewModel(studentService: widget.studentService);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) {
      _studentId = argument;
    }
    if (_viewModel.student == null) {
      _viewModel.load(_studentId);
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
        final student = _viewModel.student;
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          body: Column(
            children: [
              AppHeader(
                title: 'Detalle del estudiante',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.classroomDetail,
                  arguments: student?.classroomId ?? 'classroom-3b',
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(27, 32, 27, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 64,
                        backgroundColor: Color(0xFFD5ECF7),
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFF44515D),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Estudiante ${student?.code ?? 'COD-342'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF102532),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${student?.grade ?? 'Grado 5'} - ${student?.classroomName ?? 'Aula A'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.neutralGray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: SizedBox(
                          width: 240,
                          height: 48,
                          child: FilledButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.editStudent,
                              arguments: student?.id ?? _studentId,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFCDE7F4),
                              foregroundColor: const Color(0xFF102532),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Editar estudiante'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),
                      const Text(
                        'Detalles del Estudiante',
                        style: TextStyle(
                          color: Color(0xFF102532),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Código o seudónimo',
                              value: student?.code ?? 'COD-342',
                            ),
                            _DetailRow(
                              label: 'Edad',
                              value: '${student?.age ?? 11} años',
                            ),
                            _DetailRow(
                              label: 'Aula',
                              value: student?.classroomName ?? 'Aula A',
                            ),
                            _DetailRow(
                              label: 'Estado de\nconsentimiento',
                              value: student?.consentStatus ?? 'Aprobado',
                              badge: true,
                            ),
                            _DetailRow(
                              label: 'Último nivel de\nrevisión',
                              value:
                                  student?.revisionLevel ??
                                  'Nivel 3 -\nAvanzado',
                              last: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Acciones Rápidas',
                        style: TextStyle(
                          color: Color(0xFF102532),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _notImplemented(context),
                        child: const Text('Ver historial/evaluaciones'),
                      ),
                      OutlinedButton(
                        onPressed: () => _notImplemented(context),
                        child: const Text('Iniciar evaluación'),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.badge = false,
    this.last = false,
  });

  final String label;
  final String value;
  final bool badge;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 12, top: last ? 12 : 0),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFDDE5ED))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.neutralGray,
                fontSize: 16,
                height: 1.25,
              ),
            ),
          ),
          if (badge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEBDC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF435343),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF102532),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
        ],
      ),
    );
  }
}
