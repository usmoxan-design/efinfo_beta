import 'dart:typed_data';

class PlatformUtils {
  static Future<void> downloadBlob(Uint8List bytes, String fileName) async {
    // Not supported or handled differently on mobile (usually share/save to gallery)
  }

  static bool isTelegramWebApp() {
    return false;
  }

  static void sendTelegramData(String data) {
    // No-op on mobile
  }
}
