import 'dart:convert';

import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/views/pages/chats/customers/customer_chat_room.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NewChatWithSeller extends GetxController {
  final AuthController getxAuthController = Get.put(AuthController());
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Future<void> newCustomerWithSeller(
      String sellerId, String productId, String chatTitle,String sellerName) async {
    final String token;
    token = getxAuthController.authToken.value;
    try {
      final res = await http.post(Uri.parse('${Configs.apiServerUrl}/chat'),
          body: jsonEncode({
            "seller_id": sellerId,
            "product_id": productId,
            "chat_type": "CUSTOMER_WITH_SELLER"
          }),
          headers: {
            "X-Frontend-Token": token,
            "Content-Type": "application/json"
          });
      if (res.statusCode == 200) {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final result = resJson['result'];
        final chatId = result['id'];
        print(resJson['message']);
        if (resJson['message'] == "CHAT_ACTIVATED") {
          // ignore: avoid_print
          print('CHAT_ACTIVATED');
          Get.to(
              () => CustomerChatRoom(
                    sellerId: sellerId,
                    chatRoomId: chatId,
                    sellerName: sellerName,
                  ),
              transition: Transition.fade);
        } else {
          _sendFristMessage(chatTitle, chatId, sellerId);
          Get.to(
              () => CustomerChatRoom(
                    sellerId: sellerId,
                    chatRoomId: chatId,
                    sellerName: sellerName,
                  ),
              transition: Transition.fade);
        }
      } else {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final message = resJson['result']['message'];
        final systemMessage = resJson['result']['system_message'];
        // ignore: avoid_print
        print("message: $message");
        // ignore: avoid_print
        print("system_message: $systemMessage");
        return;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error catch $e');
      return;
    }
  }

  void _sendFristMessage(String chatTitle, String id, String sellerId) {
    final data = {
      'text': "เริ่มแชท $chatTitle",
      'sender': "seller",
      'statusRead': 1,
      "actionUrl": "",
      "actionId": "",
      "imageUrl": "",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    databaseReference
        .child('chats/${sellerId}/${id}/messages/')
        .push()
        .set(data);
    // ignore: avoid_print
    print("First Message");
  }
}
