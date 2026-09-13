import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/widgets/app_states.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_floating_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/classroom_card.dart';

import '../../domain/models/classroom.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../viewmodels/classrooms_viewmodel.dart';

class ClassroomsPage extends StatefulWidget {
  const ClassroomsPage({required this.classroomRepository, super.key});

  final ClassroomRepository classroomRepository;

  @override
  State<ClassroomsPage> createState() => _ClassroomsPageState();
}

class _ClassroomsPageState extends State<ClassroomsPage> {
  late final ClassroomsViewModel _viewModel;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ClassroomsViewModel(
      classroomRepository: widget.classroomRepository,
    );
    _viewModel.loadClassrooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _createClassroom() async {
    final created = await Navigator.pushNamed(
      context,
      AppRoutes.createClassroom,
    );
    if (created is Classroom) {
      _viewModel.addClassroom(created);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aula creada correctamente.')),
        );
      }
    }
  }

  Future<void> _openClassroom(Classroom classroom) async {
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.classroomDetail,
      arguments: classroom.classroomId,
    );
    if (updated is Classroom) {
      _viewModel.updateClassroomInList(updated);
    } else if (updated is String) {
      _viewModel.removeClassroom(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aula eliminada correctamente.')),
        );
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _viewModel.clearSearch();
      }
    });
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
          floatingActionButton: AppFloatingButton(onPressed: _createClassroom),
          body: Column(
            children: [
              AppHeader(
                title: 'Mis aulas',
                trailing: IconButton(
                  tooltip: _showSearch ? 'Cerrar búsqueda' : 'Buscar',
                  icon: Icon(
                    _showSearch ? Icons.close : Icons.search,
                    size: 26,
                  ),
                  onPressed: _toggleSearch,
                ),
              ),
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _viewModel.search,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre, grado, sección o año',
                      prefixIcon: Icon(Icons.search),
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
    if (_viewModel.errorMessage != null && _viewModel.classrooms.isEmpty) {
      return _ClassroomsErrorState(
        message: 'No se pudieron cargar las aulas.',
        onRetry: _viewModel.loadClassrooms,
      );
    }
    if (_viewModel.classrooms.isEmpty) {
      return _EmptyClassroomsState(onCreate: _createClassroom);
    }

    final classrooms = _viewModel.filteredClassrooms;
    return RefreshIndicator(
      onRefresh: _viewModel.refreshClassrooms,
      child: classrooms.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No se encontraron aulas.')),
              ],
            )
          : _buildClassroomCollection(classrooms),
    );
  }

  Widget _buildClassroomCollection(List<Classroom> classrooms) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.xl,
      AppSpacing.xl,
      120,
    ),
    children: [
      AppAdaptiveCollection(
        children: [
          for (final classroom in classrooms)
            ClassroomCard(
              classroom: classroom,
              onTap: () => _openClassroom(classroom),
            ),
        ],
      ),
    ],
  );
}

class _EmptyClassroomsState extends StatelessWidget {
  const _EmptyClassroomsState({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: 'Aún no tienes aulas registradas.',
    message: 'Crea tu primera aula para organizar a tus estudiantes.',
    icon: Icons.meeting_room_outlined,
    actionLabel: 'Crear mi primera aula',
    onAction: onCreate,
  );
}

class _ClassroomsErrorState extends StatelessWidget {
  const _ClassroomsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    title: 'No pudimos cargar las aulas',
    message: message,
    icon: Icons.cloud_off_outlined,
    actionLabel: 'Reintentar',
    onAction: onRetry,
  );
}
