import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.showBack = false,
    this.trailing,
    this.onBack,
    this.centerTitle = false,
    super.key,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD9E2EA))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Volver',
                      icon: const Icon(Icons.arrow_back, size: 25),
                      color: const Color(0xFF102532),
                      onPressed: onBack ?? () => Navigator.pop(context),
                    ),
                  ),
                Align(
                  alignment: centerTitle
                      ? Alignment.center
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: showBack && !centerTitle ? 42 : 0,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF102532),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                if (trailing != null)
                  Align(alignment: Alignment.centerRight, child: trailing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherGreetingHeader extends StatelessWidget {
  const TeacherGreetingHeader({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A2F),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryOrange,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Hola, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.neutralDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
