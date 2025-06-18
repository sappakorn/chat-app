import 'package:app/controller/chats/const_service.dart';
import 'package:app/controller/chats/new_chat_with_mbkmall.dart';
import 'package:app/views/pages/chats/select_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectService extends StatefulWidget {
  const SelectService({super.key});

  @override
  State<SelectService> createState() => _SelectServiceState();
}

class _SelectServiceState extends State<SelectService> {
  final NewChatWithMbkmall newchat = Get.put(NewChatWithMbkmall());
  final ConstService serviceType = Get.put(ConstService());

  final String blankImage =
      "https://mbk-storage.sgp1.digitaloceanspaces.com/static/sellers/mbk-logo.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(blankImage),
                radius: 23,
              ),
              SizedBox(width: 10), // ให้เว้นระยะห่างระหว่างรูปและข้อความ
              const Text('MBK SERVICE'),
            ],
          ),
          leading: IconButton(
              onPressed: () {
                Get.to(() => SelectAccount());
              },
              icon: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: Obx(() {
          if (serviceType.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return SizedBox(
            height: double.infinity,
            child: ListView.builder(
              itemCount: serviceType.types.length,
              itemBuilder: (context, index) {
                var types = serviceType.types[index];
                var title = types.label_th ?? "";
                var value = types.value;

                return ListTile(
                    leading: Image.network(
                      types.icon,
                      height: 40,
                      width: 40,
                    ),
                    title: Text(types.label_th ?? 'ไม่มีชื่อ'),
                    onTap: () {
                      newchat.newChatWithMbkMall(
                          "CUSTOMER_WITH_MBKMALL", value, title);
                    });
              },
            ),
          );
        }));
  }
}
