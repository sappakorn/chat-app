import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/models/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GetNotification extends GetxController {
  final AuthController _authController = Get.put(AuthController());

  RxList<ModelNotification> notifications = <ModelNotification>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;
  final int limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationData(forceRefresh: true);
    setupFCMListener();
  }

  void setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      fetchNotificationData(forceRefresh: true);
    });
  }

  Future<void> fetchNotificationData({bool forceRefresh = false}) async {

    if (forceRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!hasMore.value && !forceRefresh) return;
    isLoading.value = true;
    final String token = _authController.authToken.value;

    try {

      final res = await http.get(
        Uri.parse('${Configs.apiServerUrl}/notification'),
        headers: {
          "X-Frontend-Token": token,
          "X-Limit": "$limit",
          "X-Page": "${currentPage.value}",
        },
      );

      final resUtf8 = utf8.decode(res.bodyBytes);
      final resJson = jsonDecode(resUtf8);

      if (resJson.containsKey('result') &&
          resJson['result'].containsKey('data') &&
          resJson['result']['data'].containsKey('notifications')) {
        List<ModelNotification> newNotifications =
            ModelNotification.listFromJson(
          resJson['result']['data']['notifications'],
        );

        if (forceRefresh) {
          notifications.assignAll(newNotifications); // ✅ รีเฟรชใหม่หมด
        } else {
          notifications.addAll(newNotifications); // ✅ เพิ่มข้อมูลใหม่เข้าไป
        }

        hasMore.value = newNotifications.length >= limit;
        currentPage.value++;
      } else {
        print("❌ ไม่พบ Key notifications");
        hasMore.value = false;
      }
    } catch (error) {
      print("❌ Notification Error: $error");
    } finally {
      isLoading.value = false;
    }
  }
}
