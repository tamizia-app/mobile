import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../features/assessment/domain/models/writing_stroke.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class DrawingCanvasPlaceholder extends StatefulWidget {
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

  @override
  State<DrawingCanvasPlaceholder> createState() =>
      _DrawingCanvasPlaceholderState();
}

class _DrawingCanvasPlaceholderState extends State<DrawingCanvasPlaceholder> {
  final _paintKey = GlobalKey();
  int? _activePointer;

  Offset _toLocal(Offset globalPosition) {
    final box = _paintKey.currentContext!.findRenderObject()! as RenderBox;
    final point = box.globalToLocal(globalPosition);
    return Offset(
      point.dx.clamp(0.0, box.size.width),
      point.dy.clamp(0.0, box.size.height),
    );
  }

  void _endPointer(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    widget.onPanEnd();
  }

  @override
  Widget build(BuildContext context) {
    // Claim contacts immediately so a vertical stroke cannot become a scroll.
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: widget.enabled
          ? {
              EagerGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                    EagerGestureRecognizer.new,
                    (_) {},
                  ),
            }
          : {},
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (!widget.enabled || _activePointer != null) return;
          _activePointer = event.pointer;
          widget.onPanStart(_toLocal(event.position));
        },
        onPointerMove: (event) {
          if (!widget.enabled || event.pointer != _activePointer) return;
          widget.onPanUpdate(_toLocal(event.position));
        },
        onPointerUp: _endPointer,
        onPointerCancel: _endPointer,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border, width: 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.control),
            child: CustomPaint(
              key: _paintKey,
              painter: _DrawingPainter(widget.strokes),
              child: const SizedBox.expand(),
            ),
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
    _paintGuides(canvas, size);
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

  void _paintGuides(Canvas canvas, Size size) {
    final isTablet = size.width >= 500;
    final rowHeight = isTablet ? 104.0 : 88.0;
    final lineGap = isTablet ? 34.0 : 28.0;
    final inset = isTablet ? 24.0 : 16.0;
    final startY = isTablet ? 30.0 : 24.0;
    final solid = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.28)
      ..strokeWidth = 1.5;
    final middle = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.23)
      ..strokeWidth = 1.5;

    for (
      var top = startY;
      top + lineGap * 2 < size.height - 8;
      top += rowHeight
    ) {
      canvas.drawLine(
        Offset(inset, top),
        Offset(size.width - inset, top),
        solid,
      );
      final middleY = top + lineGap;
      for (var x = inset; x < size.width - inset; x += 12) {
        canvas.drawLine(
          Offset(x, middleY),
          Offset((x + 6).clamp(inset, size.width - inset), middleY),
          middle,
        );
      }
      final bottom = top + lineGap * 2;
      canvas.drawLine(
        Offset(inset, bottom),
        Offset(size.width - inset, bottom),
        solid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
