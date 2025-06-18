import 'dart:async';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/customer/customer_message.dart';
import 'package:app/views/pages/chats/customers/customer_chat_room.dart';
import 'package:app/views/pages/chats/select_account.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:app/models/chat/model_customer_message.dart';
import 'package:intl/intl.dart';

class CustomerMessage extends StatefulWidget {
  const CustomerMessage({super.key});

  @override
  State<CustomerMessage> createState() => _CustomerMessageState();
}

class _CustomerMessageState extends State<CustomerMessage> {
  final AuthController authController = Get.put(AuthController());
  final CustomerMessageController customerChatRoomController =
      Get.put(CustomerMessageController());

  final String supportImage =
      "https://mbk-storage.sgp1.digitaloceanspaces.com/icons/icon_user.png";

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String userImage = authController.customerImage.value;
      List<ModelCustomerMessage> messagesList =
          customerChatRoomController.messagesList;
      bool isLoading = customerChatRoomController.isLoading.value;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Chats"),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.to(() => SelectAccount());
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 5.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    userImage.isNotEmpty ? userImage : supportImage),
                radius: 20,
              ),
            )
          ],
        ),
        body: isLoading
            ? Center(
                child: SpinKitFadingCircle(
                  color: Color(0xFF811EA1),
                  size: 50.0,
                ),
              )
            : messagesList.isEmpty
                ? Center(child: Text("ไม่มีข้อความแชท"))
                : ListView.builder(
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      ModelCustomerMessage chat = messagesList[index];

                      return InkWell(
                        onTap: () {
                          Get.to(() => CustomerChatRoom(
                                chatRoomId: chat.chatRoomId,
                                sellerId: chat.sellerId,
                                sellerName: chat.sellerName,
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    chat.productImage ?? supportImage),
                                radius: 25,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5, // กำหนดความกว้างสูงสุด 50% ของหน้าจอ
                                      child: Text(
                                        chat.sellerName ?? 'seller name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow
                                            .ellipsis, // เพิ่มจุดไข่ปลาเมื่อข้อความเกิน
                                        maxLines: 1, // แสดงแค่ 1 บรรทัด
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        chat.lastMessage ?? "ข้อความล่าสุด",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          chat.lastMessageTime))),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      badges.Badge(
                                        badgeContent: Text(
                                          chat.statusRead
                                              .toString(), // ข้อความใน Badge
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        badgeStyle: badges.BadgeStyle(
                                          badgeColor: Colors.red,
                                          // สีของ Badge
                                          shape: badges.BadgeShape.square,
                                          // รูปทรง Badge
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          // ปรับให้เป็นรูปไข่
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          // เพิ่ม Padding
                                        ),
                                        showBadge: (chat.statusRead ?? 0) >
                                            0, // แสดง Badge เมื่อ countUnRead > 0
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Visibility(
                                        visible: chat.statusPin ==
                                            true, // ตรวจสอบเงื่อนไข
                                        child: SvgPicture.asset(
                                            'assets/chat/pinchat.svg'),
                                      ),
                                    ],
                                  ),
                                ],
                              ) // ใช้ Spacer เพื่อดันให้วงกลมอยู่ขวาสุด
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      );
    });
  }
}
