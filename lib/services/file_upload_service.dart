import 'dart:convert';
import 'dart:io';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FileUploadService extends GetxController {
  final AuthController getxAuthController = Get.put(AuthController());

  // ฟังก์ชันในการอัปโหลดไฟล์
  Future<String> uploadFile(File file, String namefile, String pathName) async {
    String token = getxAuthController.authToken.value;

    try {
      Uri url = Uri.parse('${Configs.apiServerUrl}/upload/s3');

      String mimeType = 'image/jpeg'; // เริ่มต้นเป็น JPEG

      if (namefile.endsWith('.png')) {
        mimeType = 'image/png'; // ถ้าเป็นไฟล์ PNG
      } else if (namefile.endsWith('.heic')) {
        mimeType = 'image/heic'; // ถ้าเป็นไฟล์ HEIC
      } else if (namefile.endsWith('.mov')) {
        mimeType = 'video/quicktime'; // ถ้าเป็นไฟล์ MOV
      }

      // สร้างคำขอแบบ multipart สำหรับการอัปโหลดไฟล์
      var request = http.MultipartRequest('POST', url)
        ..headers['X-Frontend-Token'] = token
        ..headers['Content-Type'] = 'multipart/form-data'
        // เพิ่มไฟล์เข้าไปใน request
        ..files.add(await http.MultipartFile.fromPath('image', file.path,
            filename: namefile, contentType: MediaType.parse(mimeType)))

        ..fields['path'] = pathName;


      var response = await request.send();

      if (response.statusCode == 200) {

        var responseData = await response.stream.bytesToString();
        var resJson = jsonDecode(responseData);
        var result = resJson['result'];

        return result['image_url'] ??
            ''; 
      } else {
        var responseData = await response.stream.bytesToString();
        var resJson = jsonDecode(responseData);
        
        print(resJson['message']);
        print('Failed to upload file: ${response.statusCode}');
        return ''; 
      }
    } catch (error) {
      print('Error Upload: $error');
      return ''; 
    }
  }
}
