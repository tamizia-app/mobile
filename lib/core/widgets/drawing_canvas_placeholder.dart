import 'package:flutter/material.dart';

import '../../features/assessment/domain/models/writing_stroke.dart';
import '../theme/app_colors.dart';

class DrawingCanvasPlaceholder extends StatelessWidget {
  const DrawingCanvasPlaceholder({
    required this.strokes,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.enabled,
    super.key,
  });

  final List<WritingStroke> strokes;
  final ValueChanged<Offset> onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;
  final bool enabled;

  bool get _hasDrawing => strokes.any((stroke) => stroke.points.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final canvasKey = GlobalKey();

    Offset toLocal(Offset globalPosition) {
      final renderBox =
          canvasKey.currentContext!.findRenderObject()! as RenderBox;
      return renderBox.globalToLocal(globalPosition);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: enabled
          ? (details) => onPanStart(toLocal(details.globalPosition))
          : null,
      onPanUpdate: enabled
          ? (details) => onPanUpdate(toLocal(details.globalPosition))
          : null,
      onPanEnd: enabled ? (_) => onPanEnd() : null,
      child: Container(
        key: canvasKey,
        height: 392,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E1EA), width: 4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _DrawingPainter(strokes),
            child: !_hasDrawing
                ? const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Escribe aquí...',
                        style: TextStyle(
                          color: Color(0xFFD5D5D5),
                          fontSize: 19,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter(this.strokes);

  final List<WritingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neutralDark
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      final points = stroke.points.map((point) => point.offset).toList();
      if (points.length < 2) {
        if (points.isNotEmpty) {
          canvas.drawCircle(points.first, 2.5, paint);
        }
        continue;
      }

      for (var index = 0; index < points.length - 1; index++) {
        canvas.drawLine(points[index], points[index + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
