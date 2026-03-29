import 'package:calorai/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

class CalorieRingPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0

  CalorieRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFEAEAEA)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..shader = const LinearGradient(
//        colors: [Color(0xFF0E0E10), Color(0xFF2C2C30)],
        colors: [primaryOrangeDark, primaryOrangeDark],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
