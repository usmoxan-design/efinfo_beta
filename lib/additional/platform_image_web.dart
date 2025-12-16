import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget getPlatformImage(String imageUrl) {
  // Har bir rasm uchun unikal kalit
  final String viewType = 'img-${imageUrl.hashCode}';

  // Rasmni ro'yxatdan o'tkazish
  // Eslatma: Bir xil viewType qayta ro'yxatdan o'tkazilsa xatolik bermaydi (idempotent),
  // lekin optimallik uchun tekshirish mumkin. Hozircha oddiylik uchun har doim register qilamiz.
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final img = html.ImageElement();
    img.src = imageUrl;
    img.style.width = '100%';
    img.style.height = '100%';
    img.style.objectFit = 'cover'; // rasmni to'ldirish
    return img;
  });

  return HtmlElementView(viewType: viewType);
}
