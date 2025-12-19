import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewBadgeWrapper extends StatelessWidget {
  final Widget child; // O'raladigan vidjet
  final String text; // Badge ichidagi yozuv (Default: "Yangi")
  final Color color; // Badge foni rangi
  final bool showBadge; // Badgeni ko'rsatish/yashirish
  final double right; // O'ngdan masofa
  final double top; // Tepadan masofa

  const NewBadgeWrapper({
    super.key,
    required this.child,
    this.text = "Yangi",
    this.color = Colors.red,
    this.showBadge = true,
    this.right = 8,
    this.top = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge) return child;

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough, // Ensures child constraints are passed through
      children: [
        child,
        Positioned(
          right: right,
          top: top,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
