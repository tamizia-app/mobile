import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/assessment_template.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/template_detail_viewmodel.dart';

class TemplateDetailPage extends StatefulWidget {
  const TemplateDetailPage({required this.assessmentRepository, super.key});

  final AssessmentRepository assessmentRepository;

  @override
  State<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  late final TemplateDetailViewModel _viewModel;
  String? _templateId;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = TemplateDetailViewModel(
      assessmentRepository: widget.assessmentRepository,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String && argument.isNotEmpty) {
      _templateId = argument;
    }
    if (!_requestedLoad && _templateId != null) {
      _requestedLoad = true;
      _viewModel.load(_templateId!);
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
        final template = _viewModel.template;
        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: template == null
              ? null
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: SafeArea(
                    child: PrimaryButton(
                      text: 'Usar plantilla',
                      icon: Icons.arrow_forward,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.assessmentConfigure,
                        arguments: template.id,
                      ),
                    ),
                  ),
                ),
          body: Column(
            children: [
              AppHeader(
                title: 'Detalle de plantilla',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.templateCatalog,
                ),
              ),
              Expanded(child: _buildContent(template)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(AssessmentTemplate? template) {
    if (_viewModel.isLoading) {
      return const AppLoadingState(message: 'Cargando información…');
    }
    if (template == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _viewModel.errorMessage ?? 'No se pudo cargar la plantilla.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _templateId == null
                    ? null
                    : () => _viewModel.load(_templateId!),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppFontSizes.display,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _DetailRow(
            label: 'Descripción',
            value: template.description ?? 'No disponible',
          ),
          _DetailRow(
            label: 'Versión',
            value: template.version?.toString() ?? 'No disponible',
          ),
          _DetailRow(
            label: 'Estado',
            value: template.isActive == null
                ? 'No disponible'
                : template.isActive!
                ? 'Activo'
                : 'Inactivo',
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Resumen de la plantilla',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            template.summary ??
                template.description ??
                'El servidor no devolvió un resumen adicional para esta plantilla.',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppFontSizes.body,
              height: 1.48,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (template.exercises.isEmpty)
            const InfoBanner(
              text:
                  'Este detalle no incluye ejercicios adjuntos. La interfaz está preparada para mostrarlos cuando el servidor los proporcione.',
            )
          else
            _TemplateExercises(exercises: template.exercises),
        ],
      ),
    );
  }
}

class _TemplateExercises extends StatelessWidget {
  const _TemplateExercises({required this.exercises});

  final List<TemplateExerciseSummary> exercises;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ejercicios',
          style: TextStyle(
            fontSize: AppFontSizes.bodyLarge,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...exercises.map(
          (exercise) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.extension_outlined,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    exercise.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (exercise.type != null)
                  Text(
                    exercise.type!,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
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
