import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/models/assessment_template.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/template_catalog_viewmodel.dart';

class TemplateCatalogPage extends StatefulWidget {
  const TemplateCatalogPage({required this.assessmentRepository, super.key});

  final AssessmentRepository assessmentRepository;

  @override
  State<TemplateCatalogPage> createState() => _TemplateCatalogPageState();
}

class _TemplateCatalogPageState extends State<TemplateCatalogPage> {
  late final TemplateCatalogViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TemplateCatalogViewModel(
      assessmentRepository: widget.assessmentRepository,
    )..load();
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
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: const AppBottomNav(
            currentItem: BottomNavItem.tests,
          ),
          body: Column(
            children: [
              AppHeader(
                title: 'Plantillas',
                trailing: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryContainer,
                  child: IconButton(
                    tooltip: 'Actualizar',
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _viewModel.load,
                  ),
                ),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const AppLoadingState(message: 'Cargando información…');
    }
    if (_viewModel.errorMessage != null && _viewModel.templates.isEmpty) {
      return _TemplatesState(
        message: _viewModel.errorMessage!,
        actionLabel: 'Reintentar',
        onAction: _viewModel.load,
      );
    }
    if (_viewModel.templates.isEmpty) {
      return const _TemplatesState(message: 'No hay plantillas disponibles.');
    }
    return RefreshIndicator(
      onRefresh: _viewModel.load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= AppBreakpoints.tablet;
          final availableWidth = constraints.maxWidth - 48;
          final cardWidth = (availableWidth - 16) / 2;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              110,
            ),
            children: [
              if (isTablet)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _viewModel.templates.map((template) {
                    return SizedBox(
                      width: cardWidth,
                      child: _buildTemplateCard(template),
                    );
                  }).toList(),
                )
              else
                ..._viewModel.templates.map(
                  (template) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTemplateCard(template),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(AssessmentTemplate template) {
    return _TemplateCard(
      template: template,
      onDetail: () => Navigator.pushNamed(
        context,
        AppRoutes.templateDetail,
        arguments: template.id,
      ),
      onSelect: () => Navigator.pushNamed(
        context,
        AppRoutes.assessmentConfigure,
        arguments: template.id,
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onDetail,
    required this.onSelect,
  });

  final AssessmentTemplate template;
  final VoidCallback onDetail;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  template.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              if (template.isActive != null)
                _MetaPill(label: template.isActive! ? 'Activo' : 'Inactivo'),
            ],
          ),
          if (template.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              template.description!,
              style: const TextStyle(
                color: AppColors.neutralGray,
                fontSize: AppFontSizes.body,
                height: 1.45,
              ),
            ),
          ],
          if (template.version != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Versión ${template.version}',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppActionGroup(
            children: [
              OutlinedButton.icon(
                onPressed: onDetail,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver detalle'),
              ),
              FilledButton.icon(
                onPressed: onSelect,
                icon: const Icon(Icons.check),
                label: const Text('Seleccionar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: AppFontSizes.support,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TemplatesState extends StatelessWidget {
  const _TemplatesState({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: onAction == null
        ? 'No hay plantillas disponibles'
        : 'No pudimos cargar las plantillas',
    message: onAction == null
        ? 'Las plantillas aparecerán aquí cuando estén disponibles. Vuelve a consultar más tarde.'
        : message,
    icon: Icons.assignment_outlined,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
