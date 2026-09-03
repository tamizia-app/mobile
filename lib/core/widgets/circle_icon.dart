import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    required this.icon,
    this.size = 64,
    this.iconSize = 32,
    super.key,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.infoBlueLight,
      ),
      child: Icon(icon, color: AppColors.primaryBlue, size: iconSize),
    );
  }
}
