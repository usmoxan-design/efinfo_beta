import 'package:flutter/material.dart';
import 'package:efinfo_beta/additional/platform_image.dart';

Widget buildPlayerImage(String imageUrl) {
  // Agar URL http bilan boshlansa (web rasm)
  if (imageUrl.startsWith('http')) {
    // Platformaga mos (Web yoki Mobile) rasmni yuklash
    return getPlatformImage(imageUrl);
  } else {
    // Agar mahalliy asset bo'lsa
    return Image.asset(
      imageUrl,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error_outline, color: Colors.red, size: 30);
      },
    );
  }
}
