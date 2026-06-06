import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import '../theme/app_colors.dart';

enum BottomNavItem { home, classrooms, exercises, tests, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentItem, super.key});

  final BottomNavItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFD9E2EA))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavButton(
              icon: Icons.home_rounded,
              label: 'Inicio',
              active: currentItem == BottomNavItem.home,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.teacherHome,
              ),
            ),
            _BottomNavButton(
              icon: Icons.bookmark_border_rounded,
              label: 'Aulas',
              active: currentItem == BottomNavItem.classrooms,
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.classrooms),
            ),
            _BottomNavButton(
              icon: Icons.extension_outlined,
              label: 'Ejercicios',
              active: currentItem == BottomNavItem.exercises,
              onTap: () => _showNotImplemented(context),
            ),
            _BottomNavButton(
              icon: Icons.content_copy_outlined,
              label: 'Pruebas',
              active: currentItem == BottomNavItem.tests,
              onTap: () => _showNotImplemented(context),
            ),
            _BottomNavButton(
              icon: Icons.settings_outlined,
              label: 'Perfil',
              active: currentItem == BottomNavItem.profile,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.teacherProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No implementado todavía')));
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryBlue : AppColors.mutedText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
