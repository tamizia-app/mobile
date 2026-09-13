import 'package:flutter/material.dart';

Future<bool> showAssessmentCancelDialog(BuildContext context) async {
  final shouldCancel = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Cancelar evaluación?'),
      content: const Text(
        'Si sales ahora, se perderá el progreso de esta evaluación.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Continuar evaluación'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Cancelar evaluación'),
        ),
      ],
    ),
  );
  return shouldCancel ?? false;
}
