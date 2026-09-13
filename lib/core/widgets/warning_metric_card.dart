import 'package:flutter/material.dart';
import 'metric_card.dart';

class WarningMetricCard extends StatelessWidget {
  const WarningMetricCard({
    required this.title,
    required this.value,
    required this.description,
    super.key,
  });
  final String title;
  final String value;
  final String description;
  @override
  Widget build(BuildContext context) => MetricCard(
    title: title,
    value: value,
    description: description,
    icon: Icons.timelapse_outlined,
  );
}
