import 'package:flutter/material.dart';

class AssessmentTimer extends StatelessWidget {
  const AssessmentTimer({this.minutes = '00', this.seconds = '15', super.key});

  final String minutes;
  final String seconds;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeBox(value: minutes, label: 'MINUTOS'),
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 28),
          child: Text(
            ':',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        _TimeBox(value: seconds, label: 'SEGUNDOS'),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDF2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD0D7DF)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF231610),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
