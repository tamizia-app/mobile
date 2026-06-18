import 'package:flutter/material.dart';

class AssessmentPauseOverlay extends StatelessWidget {
  const AssessmentPauseOverlay({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.center,
          color: Colors.white.withValues(alpha: 0.58),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Evaluación pausada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
