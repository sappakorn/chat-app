import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationService extends GetxController {
  final AuthController getxAuthController = Get.put(AuthController());

  Future<int> getCountNotification() async {
    String token = getxAuthController.authToken.value;
    final String baseUrl = "${Configs.apiServerUrl}/notification";
    try {
      final res = await http.get(Uri.parse(baseUrl), headers: {
        "X-Frontend-Token": token,
        "Content-Type": "application/json",
        'Accept': 'application/json',
        "X-Limit": "1",
        "X-Page": "1",
      });

      if (res.statusCode == 200) {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final message = resJson['message'];
        final data = resJson['result']['data'];
        if (kDebugMode) {
          print(data['unreadCount']);
          print(message);
        }
        FlutterAppBadger.updateBadgeCount(data['unreadCount']);

        return data['unreadCount'];
      } else {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final message = resJson['message'];
        // ignore: avoid_print
        print(message);
        return 0;
      }
    } catch (error) {
      if (kDebugMode) {
        print("error Get Count Noti");
        print(error);
      }
      return 0;
    }
  }
}
