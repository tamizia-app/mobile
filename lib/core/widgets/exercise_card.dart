import 'package:flutter/material.dart';

import '../../features/exercises/domain/models/exercise.dart';
import '../theme/app_colors.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.exercise,
    required this.onSelect,
    super.key,
  });

  final Exercise exercise;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9F8B66), Color(0xFFE8ECEE)],
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 92,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.title,
                        style: const TextStyle(
                          color: Color(0xFF102532),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8FE),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.neutralGray,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${exercise.estimatedDurationMinutes == 45 ? 15 : exercise.estimatedDurationMinutes} min',
                            style: const TextStyle(
                              color: AppColors.neutralGray,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  exercise.description,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.neutralGray,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: onSelect,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text(
                      'Seleccionar  →',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
