import 'package:flutter/material.dart';

import '../../features/students/domain/models/student.dart';
import '../theme/app_colors.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({required this.student, required this.onTap, super.key});

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFD5ECF7),
              child: Icon(
                Icons.person_outline,
                color: Color(0xFF44515D),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.code,
                    style: const TextStyle(
                      color: Color(0xFF102532),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Última evaluación: ${student.lastEvaluation}',
                    style: const TextStyle(
                      color: Color(0xFF3F4A55),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Edad: ${student.age}',
                    style: const TextStyle(
                      color: Color(0xFF3F4A55),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 17,
              backgroundColor: student.needsReview
                  ? const Color(0xFFFFD7D7)
                  : AppColors.successGreen,
              child: Icon(
                student.needsReview ? Icons.more_horiz : Icons.check_circle,
                color: student.needsReview
                    ? AppColors.warningRed
                    : Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
