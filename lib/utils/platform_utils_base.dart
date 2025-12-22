import 'dart:typed_data';

abstract class PlatformUtils {
  static Future<void> downloadBlob(Uint8List bytes, String fileName) async {
    throw UnsupportedError('Platform not supported');
  }

  static bool isTelegramWebApp() {
    return false;
  }

  static void sendTelegramData(String data) {
    throw UnsupportedError('Platform not supported');
  }
}
