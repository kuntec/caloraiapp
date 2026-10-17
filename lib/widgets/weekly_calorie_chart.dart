import 'dart:math';
import 'package:flutter/material.dart';

/// One day's data point for the chart.
class WeeklyCaloriePoint {
  final DateTime date;
  final double calories;
  const WeeklyCaloriePoint({required this.date, required this.calories});
}

/// A 7-day calorie line chart drawn with CustomPainter — no external packages.
class WeeklyCalorieChart extends StatelessWidget {
  final List<WeeklyCaloriePoint> points;
  final double targetCalories;

  const WeeklyCalorieChart({
    super.key,
    required this.points,
    this.targetCalories = 2000,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFFFF8B00), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF8B00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (points.isEmpty)
            const SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'Log food this week to see your progress',
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _LinePainter(
                  points: points,
                  targetCalories: targetCalories,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<WeeklyCaloriePoint> points;
  final double targetCalories;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _leftPad = 42.0;
  static const _rightPad = 12.0;
  static const _topPad = 10.0;
  static const _bottomPad = 28.0; // room for day labels

  _LinePainter({required this.points, required this.targetCalories});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final maxCal = max(
      points.map((p) => p.calories).reduce(max),
      targetCalories,
    );
    final minCal = 0.0;
    final calRange = maxCal - minCal == 0 ? 1 : maxCal - minCal;

    // --- grid lines & y-axis labels ---
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;
    final yLabelStyle = TextStyle(
      fontSize: 9,
      color: Colors.grey.shade500,
      fontWeight: FontWeight.w500,
    );

    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = _topPad + chartH * (1 - i / gridCount);
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + chartW, y),
        gridPaint,
      );
      final label = ((minCal + calRange * i / gridCount)).round().toString();
      _drawText(canvas, label, Offset(0, y - 5), yLabelStyle, maxWidth: 38);
    }

    // --- target line ---
    if (targetCalories > 0) {
      final ty = _topPad +
          chartH * (1 - (targetCalories - minCal) / calRange);
      final targetPaint = Paint()
        ..color = const Color(0xFFFF8B00).withOpacity(0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final dashPath = Path();
      double x = _leftPad;
      bool draw = true;
      while (x < _leftPad + chartW) {
        if (draw) {
          dashPath.moveTo(x, ty);
          dashPath.lineTo(min(x + 6, _leftPad + chartW), ty);
        }
        x += 10;
        draw = !draw;
      }
      canvas.drawPath(dashPath, targetPaint);
    }

    // --- compute pixel positions ---
    final n = points.length;
    final step = chartW / max(n - 1, 1);

    List<Offset> offsets = [];
    for (int i = 0; i < n; i++) {
      final x = _leftPad + i * step;
      final normY = (points[i].calories - minCal) / calRange;
      final y = _topPad + chartH * (1 - normY);
      offsets.add(Offset(x, y));
    }

    // --- gradient fill ---
    final fillPath = Path()..moveTo(offsets.first.dx, _topPad + chartH);
    for (final o in offsets) {
      fillPath.lineTo(o.dx, o.dy);
    }
    fillPath.lineTo(offsets.last.dx, _topPad + chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF8B00).withOpacity(0.25),
          const Color(0xFFFF8B00).withOpacity(0.0),
        ],
      ).createShader(
          Rect.fromLTWH(_leftPad, _topPad, chartW, chartH));
    canvas.drawPath(fillPath, fillPaint);

    // --- line ---
    final linePaint = Paint()
      ..color = const Color(0xFFFF8B00)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final cp1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // --- dots & day labels ---
    final dotPaint = Paint()
      ..color = const Color(0xFFFF8B00)
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dayLabelStyle = TextStyle(
      fontSize: 10,
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < offsets.length; i++) {
      final o = offsets[i];
      canvas.drawCircle(o, 5, dotBorderPaint);
      canvas.drawCircle(o, 3.5, dotPaint);

      // Day label
      final weekday = points[i].date.weekday; // 1=Mon...7=Sun
      final label = _dayLabels[weekday - 1];
      _drawText(
        canvas,
        label,
        Offset(o.dx - 12, size.height - _bottomPad + 6),
        dayLabelStyle,
        maxWidth: 28,
        centered: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    double maxWidth = 60,
    bool centered = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final dx = centered ? position.dx - tp.width / 2 : position.dx;
    tp.paint(canvas, Offset(dx, position.dy));
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.points != points;
}
