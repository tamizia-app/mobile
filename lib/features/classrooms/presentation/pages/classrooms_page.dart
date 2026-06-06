import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_floating_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/classroom_card.dart';
import '../../data/services/classroom_service.dart';
import '../viewmodels/classrooms_viewmodel.dart';

class ClassroomsPage extends StatefulWidget {
  const ClassroomsPage({required this.classroomService, super.key});

  final ClassroomService classroomService;

  @override
  State<ClassroomsPage> createState() => _ClassroomsPageState();
}

class _ClassroomsPageState extends State<ClassroomsPage> {
  late final ClassroomsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ClassroomsViewModel(classroomService: widget.classroomService)
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
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: const AppBottomNav(
            currentItem: BottomNavItem.classrooms,
          ),
          floatingActionButton: AppFloatingButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createClassroom),
          ),
          body: Column(
            children: [
              AppHeader(
                title: 'Mis aulas',
                trailing: IconButton(
                  tooltip: 'Buscar',
                  icon: const Icon(Icons.search, size: 26),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Búsqueda no implementada todavía'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(26, 34, 26, 120),
                  itemCount: _viewModel.classrooms.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final classroom = _viewModel.classrooms[index];
                    return ClassroomCard(
                      classroom: classroom,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.classroomDetail,
                        arguments: classroom.id,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
