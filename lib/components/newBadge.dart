import 'package:flutter/material.dart';

class NewBadgeWrapper extends StatelessWidget {
  final Widget child; // O'raladigan vidjet
  final String text; // Badge ichidagi yozuv (Default: "YANGI")
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
    this.right = 0,
    this.top = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Agar showBadge false bo'lsa, shunchaki childni o'zini qaytaradi
    if (!showBadge) return child;

    return Stack(
      clipBehavior: Clip.none, // Badge tashqariga chiqib ketishiga ruxsat beradi
      children: [
        child,
        Positioned(
          right: right,
          top: top,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
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