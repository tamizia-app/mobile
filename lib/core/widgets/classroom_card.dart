import 'package:flutter/material.dart';

import '../../features/classrooms/domain/models/classroom.dart';
import '../theme/app_colors.dart';

class ClassroomCard extends StatelessWidget {
  const ClassroomCard({
    required this.classroom,
    required this.onTap,
    super.key,
  });

  final Classroom classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    style: const TextStyle(
                      color: Color(0xFF102532),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grado: ${classroom.grade}  •  Sección: ${classroom.section}',
                    style: const TextStyle(
                      color: AppColors.neutralGray,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        color: Color(0xFF4A5A5A),
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${classroom.studentCount} Estudiantes',
                        style: const TextStyle(
                          color: Color(0xFF4A5A5A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFDDF2FF),
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF102532),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
