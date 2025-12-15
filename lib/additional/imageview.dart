import 'package:any_image_view/any_image_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// AnyImageView paketi, faqat mobil platformalar uchun foydalaniladi
// import 'package:any_image_view/any_image_view.dart'; // Sizning AnyImageView import'ingiz

Widget buildPlayerImage(String imageUrl) {
  // player.imageUrl ga o'xshash, bu yerda imageUrl deb olamiz

  // Agar WebP ni Image.network ko'rsata olmasa, va siz keshlashtirishni xohlasangiz,
  // CachedNetworkImage WebP uchun Webda Image.network'ga qaraganda yaxshiroq ishlashi mumkin.
  // Lekin avval Image.network ni sinab ko'ramiz, chunki u standart Flutter vidjeti.

  if (kIsWeb) {
    // Agar dastur Webda ishlayotgan bo'lsa, Image.network ishlatiladi.
    // Web brauzerlarining ko'pchiligi WebP ni to'g'ridan-to'g'ri qo'llab-quvvatlaydi.

    return Image.network(
      imageUrl,
      fit: BoxFit.fill,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        // WebP rasmi yuklanmasa, xato ikonkasini ko'rsatish
        print(error);
        return const Icon(Icons.error, color: Colors.redAccent, size: 40);
      },
    );
  } else {
    return AnyImageView(
      imagePath: imageUrl,
      fit: BoxFit.fill,
    );

    // **AnyImageView** ni import qila olmaganim uchun shu vidjetni misol sifatida qoldiraman
    // Siz shunchaki yuqoridagi **AnyImageView** kodini ishlatishingiz mumkin.

    // Hozircha oddiy NetworkImage ni qaytaraman, siz AnyImageView ni qaytaring.
    //  return Image.network(
    //    imageUrl,
    //    fit: BoxFit.fill,
    //    loadingBuilder: (context, child, loadingProgress) {
    //     if (loadingProgress == null) return child;
    //     return const Center(child: Text("Loading on Mobile..."));
    //   },
    //  );
  }
}
