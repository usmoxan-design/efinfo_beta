import 'package:flutter/material.dart';

class PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // --- 1. Field Background (Gradient) ---
    final fieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2e7d32), Color(0xFF1b5e20)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // --- 2. Field Shape (Perspective Trapezoid) ---
    final path = Path();
    // Top boundary (narrower)
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.9, 0);
    // Right boundary
    path.lineTo(size.width, size.height);
    // Bottom boundary (wider)
    path.lineTo(0, size.height);
    path.close();

    // Draw the green field
    canvas.drawPath(path, fieldPaint);

    // --- 3. Field Lines ---
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer boundary line
    canvas.drawPath(path, linePaint);

    // Center line
    canvas.drawLine(
      Offset(size.width * 0.05, size.height / 2),
      Offset(size.width * 0.95, size.height / 2),
      linePaint,
    );

    // Center circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.12, linePaint);

    // Top Goal Box (Narrower at the top)
    final topBox = Path();
    topBox.moveTo(size.width * 0.35, 0);
    topBox.lineTo(size.width * 0.35, size.height * 0.15);
    topBox.lineTo(size.width * 0.65, size.height * 0.15);
    topBox.lineTo(size.width * 0.65, 0);
    canvas.drawPath(topBox, linePaint);

    // Bottom Goal Box (Wider at the bottom)
    final bottomBox = Path();
    bottomBox.moveTo(size.width * 0.25, size.height);
    bottomBox.lineTo(size.width * 0.25, size.height * 0.85);
    bottomBox.lineTo(size.width * 0.75, size.height * 0.85);
    bottomBox.lineTo(size.width * 0.75, size.height);
    canvas.drawPath(bottomBox, linePaint);

    // --- 4. Watermark Text (eFinfo App) ---
    const watermarkText = 'eFinfo App';

    // Define the text style with 50% opacity and responsive font size
    final textSpan = TextSpan(
      text: watermarkText,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5), // 50% opacity
        fontSize: size.width * 0.04, // Responsive font size based on width
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );

    // Create a TextPainter
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Layout the painter to calculate its size
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Calculate position: Right side of the center (60% down, 70% across)
    // Centered around the calculated X position
    final x = size.width * 0.7 - textPainter.width / 2;
    final y = size.height * 0.6;

    // Draw the text on the canvas
    final offset = Offset(x, y);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
