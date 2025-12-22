import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

class PlatformUtils {
  static Future<void> downloadBlob(Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static bool isTelegramWebApp() {
    try {
      return js.context.hasProperty('Telegram') &&
          js.context['Telegram'].hasProperty('WebApp');
    } catch (_) {
      return false;
    }
  }

  static void sendTelegramData(String data) {
    try {
      js.context['Telegram']['WebApp'].callMethod('sendData', [data]);
    } catch (e) {
      print('Error sending telegram data: $e');
    }
  }
}
