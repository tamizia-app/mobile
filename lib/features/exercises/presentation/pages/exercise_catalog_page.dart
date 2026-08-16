import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/exercise_card.dart';
import '../../data/services/exercise_service.dart';
import '../viewmodels/exercise_catalog_viewmodel.dart';

class ExerciseCatalogPage extends StatefulWidget {
  const ExerciseCatalogPage({required this.exerciseService, super.key});

  final ExerciseService exerciseService;

  @override
  State<ExerciseCatalogPage> createState() => _ExerciseCatalogPageState();
}

class _ExerciseCatalogPageState extends State<ExerciseCatalogPage> {
  late final ExerciseCatalogViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ExerciseCatalogViewModel(
      exerciseService: widget.exerciseService,
    )..load();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          body: Column(
            children: [
              _viewModel.isSearching
                  ? _SearchHeader(
                      controller: _searchController,
                      onChanged: _viewModel.updateSearch,
                      onClose: () {
                        _searchController.clear();
                        _viewModel.toggleSearch();
                      },
                    )
                  : AppHeader(
                      title: 'Catálogo de ejercicios',
                      trailing: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFD5ECF7),
                        child: IconButton(
                          tooltip: 'Buscar',
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFF102532),
                          ),
                          onPressed: _viewModel.toggleSearch,
                        ),
                      ),
                    ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _viewModel.categories.map((category) {
                        return CategoryChip(
                          label: category.name,
                          selected:
                              category.name == _viewModel.selectedCategory,
                          onTap: () => _viewModel.selectCategory(category.name),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    if (_viewModel.filteredExercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(
                          child: Text(
                            'No se encontraron ejercicios.',
                            style: TextStyle(
                              color: AppColors.neutralGray,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._viewModel.filteredExercises.map(
                        (exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: ExerciseCard(
                            exercise: exercise,
                            onSelect: () => Navigator.pushNamed(
                              context,
                              AppRoutes.exerciseDetail,
                              arguments: exercise.id,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD9E2EA))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar ejercicios',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cerrar búsqueda',
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
