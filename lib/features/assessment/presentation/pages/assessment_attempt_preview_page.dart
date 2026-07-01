import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/assessment_attempt.dart';
import '../../domain/models/assessment_attempt_preview.dart';

class AssessmentAttemptPreviewPage extends StatelessWidget {
  const AssessmentAttemptPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is! AssessmentAttemptPreview) {
      return const _InvalidPreviewPage();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: Column(
        children: [
          AppHeader(
            title: 'Resumen del intento',
            showBack: true,
            centerTitle: true,
            onBack: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.templateCatalog,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (argument.resumedExistingAttempt) ...[
                    const _ResumeBanner(),
                    const SizedBox(height: 16),
                  ],
                  _IdentitySummary(preview: argument),
                  const SizedBox(height: 20),
                  _ConsentSummary(hasValidConsent: argument.hasValidConsent),
                  const SizedBox(height: 20),
                  _ExerciseAttemptList(
                    exerciseAttempts: argument.attempt.exerciseAttempts,
                  ),
                  const SizedBox(height: 34),
                  PrimaryButton(
                    text: 'Comenzar',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.assessmentAttemptSession,
                        arguments: argument.attempt.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentitySummary extends StatelessWidget {
  const _IdentitySummary({required this.preview});

  final AssessmentAttemptPreview preview;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Sesion',
      children: [
        _SummaryRow(label: 'Aula', value: preview.classroom.name),
        _SummaryRow(label: 'Estudiante', value: preview.student.alias),
        _SummaryRow(label: 'Plantilla', value: preview.template.name),
        _SummaryRow(
          label: 'Estado',
          value: preview.attempt.status ?? 'Intento iniciado',
        ),
      ],
    );
  }
}

class _ConsentSummary extends StatelessWidget {
  const _ConsentSummary({required this.hasValidConsent});

  final bool hasValidConsent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasValidConsent
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasValidConsent
              ? const Color(0xFF93C5FD)
              : const Color(0xFFFCA5A5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasValidConsent
                ? Icons.verified_user_outlined
                : Icons.block_outlined,
            color: hasValidConsent ? AppColors.primaryBlue : AppColors.errorRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasValidConsent
                  ? 'Consentimiento validado para iniciar el intento.'
                  : 'No hay consentimiento valido para continuar.',
              style: TextStyle(
                color: hasValidConsent
                    ? const Color(0xFF1E3A8A)
                    : AppColors.errorRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseAttemptList extends StatelessWidget {
  const _ExerciseAttemptList({required this.exerciseAttempts});

  final List<ExerciseAttempt> exerciseAttempts;

  @override
  Widget build(BuildContext context) {
    if (exerciseAttempts.isEmpty) {
      return const InfoBanner(
        text:
            'El intento fue creado, pero la respuesta no incluyo ejercicios asociados para mostrar.',
      );
    }
    return _SectionCard(
      title: 'Ejercicios del intento',
      children: exerciseAttempts
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.extension_outlined,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        if (item.type != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            translateExerciseType(item.type),
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner();

  @override
  Widget build(BuildContext context) {
    return const InfoBanner(
      text:
          'Hay un intento pendiente. Puedes continuar desde donde lo dejaste sin crear otro flujo paralelo.',
      backgroundColor: Color(0xFFEFF6FF),
      borderColor: Color(0xFF93C5FD),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvalidPreviewPage extends StatelessWidget {
  const _InvalidPreviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: 'Resumen del intento',
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text('No se recibio informacion del intento.'),
            ),
          ),
        ],
      ),
    );
  }
}
