import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../data/services/dashboard_summary_service.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/quick_action.dart';
import '../../domain/models/teacher_profile.dart';

class TeacherHomeViewModel extends ChangeNotifier {
  TeacherHomeViewModel({
    required DashboardSummaryService dashboardSummaryService,
    required AuthSessionManager sessionManager,
  }) : _dashboardSummaryService = dashboardSummaryService,
       _sessionManager = sessionManager {
    _sessionManager.addListener(_onSessionChanged);
  }

  final DashboardSummaryService _dashboardSummaryService;
  final AuthSessionManager _sessionManager;

  TeacherProfile? get profile => _sessionManager.currentTeacher;
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
      title: 'Plantillas',
      icon: Icons.assignment_outlined,
      route: AppRoutes.templateCatalog,
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
      summary = await _dashboardSummaryService.getDashboardSummary();
      errorMessage = null;
    } catch (_) {
      errorMessage = 'No se pudo cargar el dashboard.';
    }
    isLoading = false;
    notifyListeners();
  }

  void _onSessionChanged() => notifyListeners();

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    super.dispose();
  }
}
