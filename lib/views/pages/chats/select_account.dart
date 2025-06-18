import 'package:app/views/widgets/chats/service_profile.dart';
import 'package:app/views/widgets/chats/customer_chat_profile.dart';
import 'package:app/views/widgets/chats/seller_chat_profile.dart';
import 'package:app/views/widgets/notification_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectAccount extends StatefulWidget {
  const SelectAccount({super.key});

  @override
  State<SelectAccount> createState() => _SelectAccountState();
}

class _SelectAccountState extends State<SelectAccount> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "เลือกบัญชี Chat",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ปุ่มย้อนกลับ
          onPressed: () {
            Get.to(() => NotificationWidget(),
                transition: Transition.noTransition);
          },
        ),
        actions: [
          CustomerWithMbkmallWidget(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          padding: EdgeInsets.only(left: 15, right: 15),
          children: [
            SizedBox(
              height: 5,
            ),
            CustomerChatProfile(),
            SellerChatProfile(),
          ],
        ),
      ),
    );
  }
}
