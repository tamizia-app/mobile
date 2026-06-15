import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/services/teacher_service.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/quick_action.dart';
import '../../domain/models/teacher_profile.dart';

class TeacherHomeViewModel extends ChangeNotifier {
  TeacherHomeViewModel({required TeacherService teacherService})
    : _teacherService = teacherService;

  final TeacherService _teacherService;

  TeacherProfile? profile;
  DashboardSummary? summary;
  bool isLoading = false;
  String? errorMessage;

  final List<QuickAction> quickActions = const [
    QuickAction(
      title: 'Crear aula',
      icon: Icons.add_circle_outline,
      route: AppRoutes.createClassroom,
    ),
    QuickAction(
      title: 'Registrar estudiante',
      icon: Icons.person_add_alt_1,
      route: AppRoutes.createStudent,
    ),
    QuickAction(
      title: 'Catálogo',
      icon: Icons.assignment_outlined,
      route: '',
      implemented: false,
    ),
    QuickAction(
      title: 'Resultados',
      icon: Icons.bar_chart_rounded,
      route: '',
      implemented: false,
    ),
  ];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      profile = await _teacherService.getTeacherProfile();
      summary = await _teacherService.getDashboardSummary();
      errorMessage = null;
    } catch (_) {
      errorMessage = 'No se pudo cargar el dashboard.';
    }
    isLoading = false;
    notifyListeners();
  }
}
