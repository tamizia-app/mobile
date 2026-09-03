import 'package:flutter/material.dart';

class StrokePoint {
  const StrokePoint({required this.offset, required this.timestamp});

  final Offset offset;
  final DateTime timestamp;
}

class WritingStroke {
  const WritingStroke({required this.points});

  final List<StrokePoint> points;
}
