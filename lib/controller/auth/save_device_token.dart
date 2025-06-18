import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SaveDeviceToken extends GetxController {
  Future<void> saveDeviceToken(String FCMToken, String token) async {
    final baseUrl = '${Configs.apiServerUrl}/notification/device-token';

    if (kDebugMode) {
      print("FCMToken :  $FCMToken");
    }

    try {
      final response = await http.patch(Uri.parse(baseUrl), headers: {
        "X-Frontend-Token": token,
        "X-Device-Token": FCMToken,
        "Content-Type": "application/json",
        'Accept': 'application/json',
      }, body: jsonEncode({
        "device_type": "IOS" // IOS , ANDROID , WEB
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
          print(res['result']['message']);
          print(res['result']['system_message']);
          return;
        }
      }
    } catch (error) {
      print(error);

      return;
    }
  }
}
