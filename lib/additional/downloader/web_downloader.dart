import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadImage(Uint8List bytes, String fileName) async {
  final blob = html.Blob([bytes], 'image/png');

  // Web Share API orqali ulashishga urinib ko'rish (Mobil brauzerlar va TWA uchun)
  try {
    // html.File konstruktori: (bits, name, [options])
    final file = html.File([blob], '$fileName.png', {'type': 'image/png'});

    // Navigator.share(data)
    // Kichik hiyla: dart:html da share files'ni qo'llab quvvatlamasligi mumkin,
    // shuning uchun biz oddiy map uzatamiz. Agar ishlamasa catch'ga tushadi.
    // Hozirgi dart SDK da share metodi Map qabul qiladi.
    await html.window.navigator.share({
      'files': [file],
      'title': 'Squad Image',
      'text': 'My Squad'
    });
    return; // Agar share ochilsa, download kerak emas
  } catch (e) {
    // Share bekor qilinsa yoki xato bersa (yoki desktopda bo'lsa), oddiy downloadga o'tamiz
    print("Share API error or not supported: $e");
  }

  // Fallback: Oddiy yuklab olish
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "$fileName.png")
    ..click();
  html.Url.revokeObjectUrl(url);
}
