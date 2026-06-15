import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/quick_action_card.dart';
import '../../../../core/widgets/warning_metric_card.dart';
import '../../data/services/teacher_service.dart';
import '../viewmodels/teacher_home_viewmodel.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({required this.teacherService, super.key});

  final TeacherService teacherService;

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  late final TeacherHomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TeacherHomeViewModel(teacherService: widget.teacherService)
      ..load();
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
                name: _viewModel.profile?.firstName ?? 'Docente',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                        children: [
                          MetricCard(
                            title: 'Aulas',
                            value: '${summary?.classrooms ?? 12}',
                            icon: Icons.bookmark_border_rounded,
                          ),
                          MetricCard(
                            title: 'Estudiantes',
                            value: '${summary?.students ?? 145}',
                            icon: Icons.people_alt_outlined,
                          ),
                          MetricCard(
                            title: 'Evaluaciones',
                            value: '${summary?.evaluations ?? 89}',
                            icon: Icons.assignment_outlined,
                          ),
                          WarningMetricCard(
                            title: 'Revisión sugerida',
                            value: '${summary?.suggestedReviews ?? 5}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const InfoBanner(
                        text:
                            'Esta herramienta es de apoyo pedagógico y no reemplaza una evaluación clínica especializada.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Accesos rápidos',
                        style: TextStyle(
                          color: AppColors.neutralDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.42,
                        children: _viewModel.quickActions.map((action) {
                          return QuickActionCard(
                            title: action.title,
                            icon: action.icon,
                            onTap: () {
                              if (!action.implemented) {
                                _showNotImplemented(context);
                                return;
                              }
                              Navigator.pushNamed(context, action.route);
                            },
                          );
                        }).toList(),
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

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No implementado todavía')));
  }
}
