import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/customer/customer_message.dart';
import 'package:app/controller/chats/seller/seller_message.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PinChatService extends GetxController {
  final AuthController getxAuthController = Get.put(AuthController());
  final CustomerMessageController customerMessageController =
      Get.put(CustomerMessageController());
  final SellerMessageController sellerMessageController =
      Get.put(SellerMessageController());
  Future<void> pinChat(String chatId) async {
    String token = getxAuthController.authToken.value;
    try {
      final res = await http.patch(
          Uri.parse('${Configs.apiServerUrl}/chat/pin/$chatId'),
          headers: {
            "X-Frontend-Token": token,
          });
      if (res.statusCode == 200) {
        final resutf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resutf8);
        if (kDebugMode) {
          print(resJson['message']);
        }
        customerMessageController.fetchChatData();
        sellerMessageController.fetchChatData();
      } else {
        final resJson = jsonDecode(res.body);
        if (kDebugMode) {
          print(resJson['message']);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }
}
