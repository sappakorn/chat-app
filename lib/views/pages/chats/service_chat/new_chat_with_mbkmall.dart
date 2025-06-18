import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ChatWithMbkmall extends StatefulWidget {
  const ChatWithMbkmall({super.key});

  @override
  State<ChatWithMbkmall> createState() => _ChatWithMbkmallState();
}

class _ChatWithMbkmallState extends State<ChatWithMbkmall> {
  final AuthController getxAuthController = Get.put(AuthController());
  final TextEditingController _chatType = TextEditingController();
  final TextEditingController _serviceType = TextEditingController();

  Future<void> _newChatWithMbkMall() async {
    final String customerToken;
    customerToken = getxAuthController.authToken.value;
    try {
      final res = await http.post(Uri.parse('${Configs.apiServerUrl}/chat'),
          body: jsonEncode(
              {"chat_type": _chatType.text, "service_type": _serviceType.text}),
          headers: {
            "X-Frontend-Token": customerToken,
            "Content-Type": "application/json"
          });
      if (res.statusCode == 200) {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final result = resJson['result'];
        final chatid = result['id'];
        if (result['message'] == "CHAT_ACTIVATED") {
          // ignore: avoid_print
          print('CHAT_ACTIVATED');
          return;
        } else {
          setState(() {
            newChatWithShop(chatid);
          });
        }
      } else {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final message = resJson['result']['message'];
        final systemMessage = resJson['result']['system_messge'];
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

  void newChatWithShop(String id) {
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('chats/$id/messages/').set("");
    // ignore: avoid_print
    print("New chat with mbk-mall success ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CHAT WITH MBK MALL"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Text("กรอก service_type และ chat_type"),
              SizedBox(
                height: 40,
              ),
              TextField(
                controller: _serviceType,
                decoration: InputDecoration(hintText: "SERVICE TYPE"),
              ),
              SizedBox(
                height: 40,
              ),
              TextField(
                controller: _chatType,
                decoration: InputDecoration(hintText: "CHAT TYPE"),
              ),
              SizedBox(
                height: 40,
              ),
              MaterialButton(
                onPressed: _newChatWithMbkMall,
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 300,
                height: 50,
                child: const Text(
                  "New Chat",
                  style: TextStyle(fontSize: 18.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
