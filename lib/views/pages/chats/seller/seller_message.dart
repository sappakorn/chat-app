import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/seller/seller_message.dart';
import 'package:app/models/chat/model_seller_message.dart';
import 'package:app/views/pages/chats/select_account.dart';
import 'package:app/views/pages/chats/seller/seller_chat_room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';

class SellerMessage extends StatefulWidget {
  const SellerMessage({super.key});

  @override
  State<SellerMessage> createState() => _SellerMessageState();
}

class _SellerMessageState extends State<SellerMessage> {
  final AuthController _authController = Get.put(AuthController());
  final SellerMessageController sellerMessageController =
      Get.put(SellerMessageController());

  final String supportImage =
      "https://mbk-storage.sgp1.digitaloceanspaces.com/icons/icon_user.png";

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String userImage = _authController.sellerImage.value;
      List<ModelSellerMessage> messageList =
          sellerMessageController.messagesList;
      bool isLoading = sellerMessageController.isLoading.value;

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
              padding: const EdgeInsets.only(right: 12, top: 5),
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
              ))
            : messageList.isEmpty
                ? Center(child: Text("ไม่มีข้อความแชท"))
                : ListView.builder(
                    itemCount: messageList.length,
                    itemBuilder: (context, index) {
                      ModelSellerMessage chat = messageList[index];

                      return InkWell(
                        onTap: () {
                          Get.to(() => SellerChatRoom(
                                chatRoom: chat.chatRoomId,
                                customerIamge: chat.customerImage,
                                customerName: chat.customerName,
                                sellerId: chat.sellerId,
                                customerId: chat.customerId,
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    chat.customerImage ?? supportImage),
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
                                        chat.sellerName ?? 'customer name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                              ) // ใช้ Spacer
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
