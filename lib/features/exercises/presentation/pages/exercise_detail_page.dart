import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_colors.dart';

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
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise?.detailTitle ??
                            'Análisis de comprensión lectora',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppFontSizes.display,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _InfoRow(
                        label: 'Tipo de\nejercicio',
                        value: exercise?.typeLabel ?? 'Lectura y escritura',
                      ),
                      _InfoRow(
                        label: 'Grado\nrecomendado',
                        value:
                            exercise?.recommendedGrade ??
                            '3.er grado de primaria',
                      ),
                      _InfoRow(
                        label: 'Duración\nestimada',
                        value:
                            '${exercise?.estimatedDurationMinutes ?? 45} minutos',
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      const Text(
                        'Instrucciones para el docente',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        exercise?.instructionsForTeacher ?? '',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppFontSizes.body,
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
  Widget build(BuildContext context) =>
      AppDetailRow(label: label, value: value);
}
