import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
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
                  backgroundColor: const Color(0xFFD5ECF7),
                  child: IconButton(
                    tooltip: 'Actualizar',
                    icon: const Icon(Icons.refresh, color: Color(0xFF102532)),
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
      return const Center(child: CircularProgressIndicator());
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
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
        itemCount: _viewModel.templates.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final template = _viewModel.templates[index];
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
        },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                    color: Color(0xFF102532),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              if (template.isActive != null) _MetaPill(label: template.isActive! ? 'Activo' : 'Inactivo'),
            ],
          ),
          if (template.description != null) ...[
            const SizedBox(height: 10),
            Text(
              template.description!,
              style: const TextStyle(
                color: AppColors.neutralGray,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ],
          if (template.version != null) ...[
            const SizedBox(height: 12),
            Text(
              'Versión ${template.version}',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDetail,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver detalle'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.check),
                  label: const Text('Seleccionar'),
                ),
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
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1E40AF),
          fontSize: 12,
          fontWeight: FontWeight.w800,
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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.assignment_outlined,
              color: AppColors.mutedText,
              size: 54,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
