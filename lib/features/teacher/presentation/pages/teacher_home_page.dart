import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';

import '../../../../core/theme/app_tokens.dart';

import '../../../../core/widgets/error_message.dart';

import '../../../../core/widgets/app_states.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/quick_action_card.dart';

import '../../../../core/widgets/warning_metric_card.dart';
import '../../data/services/dashboard_summary_service.dart';
import '../viewmodels/teacher_home_viewmodel.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({
    required this.dashboardSummaryService,
    required this.sessionManager,
    super.key,
  });

  final DashboardSummaryService dashboardSummaryService;
  final AuthSessionManager sessionManager;

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  late final TeacherHomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TeacherHomeViewModel(
      dashboardSummaryService: widget.dashboardSummaryService,
      sessionManager: widget.sessionManager,
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
        final summary = _viewModel.summary;
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: const AppBottomNav(
            currentItem: BottomNavItem.home,
          ),
          body: Column(
            children: [
              TeacherGreetingHeader(
                name: _viewModel.profile?.name ?? 'Docente',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppSectionHeader(
                        title: 'Tu espacio de trabajo',
                        description:
                            'Organiza tus aulas y acompaña cada evaluación.',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppAdaptiveCollection(
                        minItemWidth: 260,
                        children: _viewModel.quickActions
                            .map(
                              (action) => QuickActionCard(
                                title: !action.implemented
                                    ? 'Historial de estudiantes'
                                    : action.route == AppRoutes.createStudent
                                    ? 'Registrar en un aula'
                                    : action.title,
                                icon: action.icon,
                                onTap: () {
                                  if (!action.implemented) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.studentsList,
                                    );
                                    return;
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    action.route == AppRoutes.createStudent
                                        ? AppRoutes.classrooms
                                        : action.route,
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppSectionHeader(title: 'Tu actividad'),
                      if (_viewModel.isLoading)
                        const AppLoadingState(
                          message: 'Actualizando tu resumen…',
                        ),
                      if (_viewModel.errorMessage != null) ...[
                        ErrorMessage(text: _viewModel.errorMessage!),
                        TextButton(
                          onPressed: _viewModel.isLoading
                              ? null
                              : _viewModel.load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                      AppAdaptiveCollection(
                        minItemWidth: 130,
                        maxColumns: 4,
                        children: [
                          MetricCard(
                            title: 'Aulas',
                            value: summary?.totalClassrooms.toString() ?? '—',
                            description: 'A tu cargo',
                            icon: Icons.meeting_room_outlined,
                          ),
                          MetricCard(
                            title: 'Estudiantes',
                            value: summary?.totalStudents.toString() ?? '—',
                            description: 'Activos en tus aulas',
                            icon: Icons.people_outline,
                          ),
                          MetricCard(
                            title: 'Evaluaciones',
                            value: summary?.totalAssessments.toString() ?? '—',
                            description: 'Creadas por ti',
                            icon: Icons.assignment_outlined,
                          ),
                          WarningMetricCard(
                            title: 'En progreso',
                            value:
                                summary?.inProgressAttempts.toString() ?? '—',
                            description: 'Intentos sin finalizar',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const InfoBanner(
                        text:
                            'TamizIA apoya el seguimiento pedagógico. Sus resultados son orientativos y no constituyen un diagnóstico clínico.',
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
