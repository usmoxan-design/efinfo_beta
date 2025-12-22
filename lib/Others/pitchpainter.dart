import 'package:flutter/material.dart';

class PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // --- 1. Field Background (Gradient) ---
    final fieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF1B5E20)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw base green field
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fieldPaint);

    // --- 2. Grass Stripes ---
    final stripePaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    double stripeHeight = size.height / 10;
    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
            Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
            stripePaint);
      }
    }

    // --- 3. Field Lines ---
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Outer boundary line with padding
    double padding = 8.0;
    Rect fieldRect = Rect.fromLTWH(
        padding, padding, size.width - 2 * padding, size.height - 2 * padding);
    canvas.drawRect(fieldRect, linePaint);

    // Center line
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      linePaint,
    );

    // Center circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.15, linePaint);

    // Center point
    final pointPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 2, pointPaint);

    // Top Penalty Box (Large)
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.2, padding, size.width * 0.6, size.height * 0.18),
        linePaint);
    // Top Goal Box (Small)
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.35, padding, size.width * 0.3, size.height * 0.06),
        linePaint);
    // Top Penalty Arc
    canvas.drawArc(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.14, size.width * 0.2,
            size.height * 0.08),
        0.1,
        3.0,
        false,
        linePaint);

    // Bottom Penalty Box (Large)
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.2,
            size.height - size.height * 0.18 - padding,
            size.width * 0.6,
            size.height * 0.18),
        linePaint);
    // Bottom Goal Box (Small)
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.35,
            size.height - size.height * 0.06 - padding,
            size.width * 0.3,
            size.height * 0.06),
        linePaint);
    // Bottom Penalty Arc
    canvas.drawArc(
        Rect.fromLTWH(
            size.width * 0.4,
            size.height - size.height * 0.22 - padding,
            size.width * 0.2,
            size.height * 0.08),
        3.2,
        3.0,
        false,
        linePaint);

    // --- 4. Watermark / Corner Decoration ---
    _drawWatermark(canvas, size);
  }

  void _drawWatermark(Canvas canvas, Size size) {
    const watermarkText = 'EFINFO';
    final textPainter = TextPainter(
      text: TextSpan(
        text: watermarkText,
        style: TextStyle(
          color: Colors.white.withOpacity(0.12),
          fontSize: size.width * 0.1,
          fontWeight: FontWeight.w900,
          letterSpacing: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.5);
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
