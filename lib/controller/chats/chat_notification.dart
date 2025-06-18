import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  final AuthController _authController = Get.put(AuthController());


  Future<void> chatNotification(String reciver, String reciverId, String title,
      String message, String image, String chatId) async {
    final baseUrl = '${Configs.apiServerUrl}/notification/chat-notification';
    String token = _authController.authToken.value;

    try {
      final response = await http.post(Uri.parse(baseUrl), headers: {
        "X-Frontend-Token": token,
        "Content-Type": "application/json",
        'Accept': 'application/json',
      }, 
      body: jsonEncode({
        "reciver": reciver,
        "reciver_id": reciverId,
        "title": title,
        "message": message,
        "image": image,
        "action_url": "https://web-frontend-dev.mbkmall.com", // กดแล้วไปไหน
        "chat_id": chatId      
      }));

      final resutf8 = utf8.decode(response.bodyBytes);
      final res = jsonDecode(resutf8);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.statusCode);
          final message = res['result']['message'];

          print("message : $message");
        }
        return;
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print("error chat notification");
          print(res['result']['message']);
          return;
        }
      }
    } catch (error) {
      print(error);

      return;
    }
  }
}
