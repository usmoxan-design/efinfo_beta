import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// YANGI IMPORT
import 'package:saver_gallery/saver_gallery.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/additional/downloader/downloader.dart';

class ImagePreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;
  const ImagePreviewScreen({super.key, required this.imageBytes});

  // Ruxsat so'rash mantiqi (Android va iOS uchun)
  Future<bool> _requestPermission() async {
    // Android 13+ uchun MediaImages ruxsati
    if (defaultTargetPlatform == TargetPlatform.android &&
        await Permission.photos.request().isGranted) {
      return true;
    }
    // Android 12 va undan past, yoki iOS uchun umumiy Storage/Photos ruxsati
    if (await Permission.storage.request().isGranted ||
        await Permission.photos.request().isGranted) {
      return true;
    }
    return false;
  }

  // --- Yangilangan Saqlash Funksiyasi (Loading bilan) ---
  Future<void> _saveImageToGallery(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final String fileName = 'Squad_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Loading dialogini ko'rsatish
    _showLoadingDialog(context);

    try {
      if (kIsWeb) {
        // --- WEB UCHUN MANTIQ ---
        // Avval Share API ni sinaydi, bo'lmasa Browser Download qiladi
        await downloadImage(imageBytes, fileName);

        // Loading dialogini yopish
        Navigator.pop(context);

        messenger.showSnackBar(
          const SnackBar(
            content: Text(
                "Jarayon yakunlandi. Agar saqlanmasa, rasm ustiga bosib saqlang."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        // --- MOBIL (Android/iOS) UCHUN MANTIQ ---

        // 2. Ruxsat so'rash
        if (!await _requestPermission()) {
          // Ruxsat olinmasa, dialogni yopish va xabarni ko'rsatish
          Navigator.pop(context);
          messenger.showSnackBar(
            const SnackBar(
                content: Text(
                    "Rasm saqlash uchun ruxsat berilmadi. Iltimos, sozlamalarni tekshiring."),
                backgroundColor: Colors.red),
          );
          return;
        }

        // 3. SaverGallery orqali rasmni to'g'ridan-to'g'ri Gallereyaga saqlash
        final result = await SaverGallery.saveImage(
          imageBytes,
          fileName: fileName,
          androidRelativePath: "Pictures/SquadBuilder",
          quality: 100,
          skipIfExists: false,
        );

        // 4. Loading dialogini yopish
        Navigator.pop(context);

        // 5. Natijani tekshirish va SnackBar ko'rsatish
        if (result.isSuccess) {
          messenger.showSnackBar(
            const SnackBar(
                content: Text("Rasm Galereyaga muvaffaqiyatli saqlandi! 🥳"),
                backgroundColor: Colors.green),
          );
        } else {
          // Xatoni aniqlash uchun toString ishlatamiz, chunki errorMsg har xil versiyalarda farq qilishi mumkin
          throw Exception("Saqlashda xato: ${result.toString()}");
        }
      }
    } catch (e) {
      // Xato yuz berganda ham loading dialogini yopish (agar ochiq bo'lsa)
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }

      if (kDebugMode) {
        print("Saqlashda xato: $e");
      }
      messenger.showSnackBar(
        SnackBar(
            content: Text(
                "Xatolik yuz berdi: ${e.toString().split(":").last.trim()}"),
            backgroundColor: Colors.red),
      );
    }
  }

  // --- Yangi Loading Dialog funksiyasi ---
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Foydalanuvchi orqaga bosib yopa olmaydi
      builder: (context) {
        return Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: Card(
              color: AppColors.cardSurface
                  .withOpacity(0.8), // Orqasini biroz shaffof qora qilish
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: AppColors.accent, // Loading rangini accent qilish
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Galereyaga Saqlash",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.accent),
            onPressed: () => _saveImageToGallery(context),
            tooltip: "Rasmni Gallereyaga saqlash",
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          // Rasmni kattalashtirish va surish imkoniyatini beradi
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// Xato xabarlarni to'g'ri olish uchun (agar SaverGallery funksiyasi `errorMsg`ni null qaytarsa)
extension on SaveResult {
  // SaveResult sinfida errorMsg metodi mavjud bo'lishi kerak.
  // Agar u mavjud bo'lmasa yoki null qaytarsa, oldingi kod buzilishi mumkin.
  // Hozircha uni shunchaki String? deb qabul qilamiz.
  String? get errorMsg => null;
}
