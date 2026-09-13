import 'package:flutter/material.dart';

class QuickAction {
  const QuickAction({
    required this.title,
    required this.icon,
    required this.route,
    this.implemented = true,
  });

  final String title;
  final IconData icon;
  final String route;
  final bool implemented;
}
