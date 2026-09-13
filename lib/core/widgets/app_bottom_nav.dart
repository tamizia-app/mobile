import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

enum BottomNavItem { home, classrooms, tests, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentItem, super.key});
  final BottomNavItem currentItem;
  @override
  Widget build(BuildContext context) {
    const destinations = [
      ('Inicio', Icons.home_outlined, AppRoutes.teacherHome),
      ('Aulas', Icons.meeting_room_outlined, AppRoutes.classrooms),
      ('Pruebas', Icons.assignment_outlined, AppRoutes.templateCatalog),
      ('Perfil', Icons.person_outline_rounded, AppRoutes.teacherProfile),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: Semantics(
                    selected: currentItem.index == index,
                    button: true,
                    child: InkWell(
                      onTap: currentItem.index == index
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context,
                              destinations[index].$3,
                            ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: currentItem.index == index
                                    ? AppColors.primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.control,
                                ),
                              ),
                              child: Icon(
                                destinations[index].$2,
                                color: currentItem.index == index
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              destinations[index].$1,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: currentItem.index == index
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
