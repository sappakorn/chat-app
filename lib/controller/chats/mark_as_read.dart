import 'dart:convert';

import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/notification/get_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MarkAsRead extends GetxController {
  final AuthController _authController = Get.put(AuthController());
  final GetNotification getNotification = Get.put(GetNotification());
  RxInt updateCountRead = 0.obs;
  Future<void> markAsRead(String chatId) async {
    final baseUrl = '${Configs.apiServerUrl}/notification/chat/$chatId';
    String token = _authController.authToken.value;

    try {
      final response = await http.patch(Uri.parse(baseUrl), headers: {
        "X-Frontend-Token": token,
        "Content-Type": "application/json",
        'Accept': 'application/json',
      });

      final resutf8 = utf8.decode(response.bodyBytes);
      final res = jsonDecode(resutf8);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.statusCode);
          final message = res['result']['message'];
          print("message : $message");
        }
        final unreadCount = res['result']['unreadCount'];
        print("Update Success");
        await FlutterAppBadger.updateBadgeCount(unreadCount);
        updateCountRead.value = unreadCount;
        await getNotification.fetchNotificationData(forceRefresh: true);

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
