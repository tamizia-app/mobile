import 'package:flutter/material.dart';

import '../constants/app_routes.dart';

class BackHeader extends StatelessWidget {
  const BackHeader({
    required this.title,
    this.outsideCard = false,
    this.onBack,
    super.key,
  });

  final String title;
  final bool outsideCard;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: outsideCard ? 40 : 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: outsideCard
                  ? const Color(0xFF102532)
                  : const Color(0xFF1F2937),
              fontSize: outsideCard ? 19 : 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Volver',
              icon: Icon(
                Icons.arrow_back,
                color: outsideCard
                    ? const Color(0xFF0F2A36)
                    : const Color(0xFF4B5563),
                size: outsideCard ? 28 : 22,
              ),
              onPressed:
                  onBack ??
                  () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
            ),
          ),
        ],
      ),
    );
  }
}
