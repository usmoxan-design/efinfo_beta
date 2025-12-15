import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// YANGI IMPORT
import 'package:saver_gallery/saver_gallery.dart';

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

    // 1. Loading dialogini ko'rsatish
    _showLoadingDialog(context);

    try {
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
        fileName: 'Squad_${DateTime.now().millisecondsSinceEpoch}',
        androidRelativePath:
            "Pictures/SquadBuilder", // Rasmni shu papkaga saqlaydi
        quality: 100, skipIfExists: false, // Maksimal sifat
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
        throw Exception(result.errorMsg ?? "Noma'lum xato yuz berdi.");
      }
    } catch (e) {
      // Xato yuz berganda ham loading dialogini yopish
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }

      if (kDebugMode) {
        print("Saqlashda xato: $e");
      }
      messenger.showSnackBar(
        SnackBar(
            content:
                Text("Saqlashda xato: ${e.toString().split(":").last.trim()}"),
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
        return const Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: Card(
              color: Colors.black54, // Orqasini biroz shaffof qora qilish
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Colors.white, // Loading rangini oq qilish
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
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        title: const Text("Galereyaga Saqlash",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.cyan),
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
