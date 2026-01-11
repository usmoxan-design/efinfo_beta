import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageKitService {
  // TODO: ALOHIDA DIQQAT! Bu kalitlarni ImageKit dashboardidan oling.
  // Xavfsizlik uchun Private Keyni ilova ichida saqlash tavsiya etilmaydi,
  // lekin hozircha to'liq ishlashi uchun shu usuldan foydalanamiz.
  static const String publicKey = "public_UOGjkLPwsFLbdHurOzaVrrqoI9A=";
  static const String privateKey = "private_uq4LVvu35CoaYsA7DdiOas1VGhE=";
  static const String urlEndpoint = "https://ik.imagekit.io/usmoxan/";

  static Future<Map<String, dynamic>?> uploadImage(
      File file, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
      );

      // Authorization header (Basic Auth: base64(privateKey:))
      String auth = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}';
      request.headers.addAll({
        'Authorization': auth,
      });

      request.fields['fileName'] = fileName;
      request.fields['useUniqueFileName'] = 'true';
      request.fields['folder'] = '/marketplace/';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      } else {
        print("ImageKit Upload Error: ${response.statusCode} - $responseData");
        return null;
      }
    } catch (e) {
      print("ImageKit Upload Catch Error: $e");
      return null;
    }
  }

  static Future<bool> deleteImage(String fileId) async {
    try {
      String auth = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}';
      var response = await http.delete(
        Uri.parse('https://api.imagekit.io/v1/files/$fileId'),
        headers: {
          'Authorization': auth,
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        print(
            "ImageKit Delete Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("ImageKit Delete Catch Error: $e");
      return false;
    }
  }
}
