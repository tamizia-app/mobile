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
    final inset = isTablet ? 24.0 : 18.0;
    final gap = isTablet ? 18.0 : 16.0;
    final targetHeight = isTablet ? 100.0 : 96.0;
    final availableHeight = size.height - 32;
    final possibleRows = ((availableHeight + gap) / (targetHeight + gap))
        .floor();
    final rowCount = possibleRows < 1 ? 1 : possibleRows;
    final rowHeight = (availableHeight - (rowCount - 1) * gap) / rowCount;
    final fill = Paint()..color = const Color(0xFFC4EDFB);
    final white = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = const Color(0xFF1FAAD3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final startMarker = Paint()..color = AppColors.brandOrange;

    for (var index = 0; index < rowCount; index++) {
      final top = 16.0 + index * (rowHeight + gap);
      final rect = Rect.fromLTWH(inset, top, size.width - inset * 2, rowHeight);
      final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(22));
      canvas.drawRRect(rounded, fill);
      canvas.drawRect(
        Rect.fromLTRB(
          rect.left + 2,
          rect.top + rowHeight * 0.28,
          rect.right - 2,
          rect.bottom - rowHeight * 0.28,
        ),
        white,
      );
      canvas.drawRRect(rounded, outline);
      if (index == 0) {
        final middle = rect.center.dy;
        final marker = Path()
          ..moveTo(inset - 12, middle - 8)
          ..lineTo(inset - 3, middle)
          ..lineTo(inset - 12, middle + 8)
          ..close();
        canvas.drawPath(marker, startMarker);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
