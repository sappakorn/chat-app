import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/views/pages/chats/service_chat/service_chat_room.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class NewChatWithMbkmall extends GetxController {
  final AuthController getxAuthController = Get.put(AuthController());
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Future<void> newChatWithMbkMall(
      String chatType, String serviceType, String chatTitle) async {
    final String customerToken;
    customerToken = getxAuthController.authToken.value;
    try {
      final res = await http.post(Uri.parse('${Configs.apiServerUrl}/chat'),
          body: jsonEncode({
            "chat_type": chatType,
            "service_type": serviceType,
          }),
          headers: {
            "X-Frontend-Token": customerToken,
            "Content-Type": "application/json"
          });
      if (res.statusCode == 200) {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final result = resJson['result'];
        final chatId = result['id'];
        if (resJson['message'] == "CHAT_ACTIVATED") {
          // ignore: avoid_print
          print('CHAT_ACTIVATED');
          Get.to(
              () => ServiceChatRoom(
                    serviceType: serviceType,
                    chatRoomId: chatId,
                  ),
              transition: Transition.fade);
        } else {
          _sendFristMessage(serviceType, chatId, chatTitle);

          Get.to(
              () => ServiceChatRoom(
                    serviceType: serviceType,
                    chatRoomId: chatId,
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

  void _sendFristMessage(String serviceType, String id, String chatTitle) {
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
        .child('chats/${serviceType}/${id}/messages/')
        .push()
        .set(data);
    // ignore: avoid_print
    print("First Message");
  }
}
