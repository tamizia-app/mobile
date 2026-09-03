import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/services/exercise_service.dart';
import '../viewmodels/exercise_detail_viewmodel.dart';

class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({required this.exerciseService, super.key});

  final ExerciseService exerciseService;

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late final ExerciseDetailViewModel _viewModel;
  String _exerciseId = 'visual-vocabulary';

  @override
  void initState() {
    super.initState();
    _viewModel = ExerciseDetailViewModel(
      exerciseService: widget.exerciseService,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) _exerciseId = argument;
    if (_viewModel.exercise == null) _viewModel.load(_exerciseId);
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
        final exercise = _viewModel.exercise;
        return Scaffold(
          backgroundColor: const Color(0xFFFAFBFC),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
            child: SafeArea(
              child: PrimaryButton(
                text: 'Ver plantillas',
                icon: Icons.assignment_outlined,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.templateCatalog),
              ),
            ),
          ),
          body: Column(
            children: [
              AppHeader(
                title: 'Detalle del ejercicio',
                showBack: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.exerciseCatalog,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise?.detailTitle ??
                            'Análisis de comprensión lectora',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _InfoRow(
                        label: 'Tipo de\nejercicio',
                        value: exercise?.typeLabel ?? 'Lectura y escritura',
                      ),
                      _InfoRow(
                        label: 'Grado\nrecomendado',
                        value: exercise?.recommendedGrade ?? '3.er grado de primaria',
                      ),
                      _InfoRow(
                        label: 'Duración\nestimada',
                        value:
                            '${exercise?.estimatedDurationMinutes ?? 45} minutos',
                      ),
                      const SizedBox(height: 38),
                      const Text(
                        'Instrucciones para el docente',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        exercise?.instructionsForTeacher ?? '',
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          height: 1.48,
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFCDD6E0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4C74A0),
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
