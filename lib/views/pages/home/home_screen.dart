import 'package:app/controller/notification/get_notification.dart';
import 'package:app/views/widgets/card_product.dart';
import 'dart:async';
import 'package:app/controller/auth/logout.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/views/widgets/notification_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetxLogoutController getxLogoutController =
      Get.put(GetxLogoutController());
  final NotificationService _noti = Get.put(NotificationService());

  final GetNotification notiController = Get.put(GetNotification());

  StreamSubscription? _messageSubscription;
  int unreadCount = 0;

  Color colorNoClick = Color(0xFF9E9E9E);
  Color colorClick = Color(0xFF811EA1);

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _setupFCMListener();
  }

  Future<void> _fetchUnreadCount() async {
    int count = await _noti.getCountNotification();
    setState(() {
      unreadCount = count;
    });
  }

  void _setupFCMListener() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // อัปเดตตัวแปร unreadCount ทันทีที่ได้รับการแจ้งเตือนใหม่
      if (mounted) {
        setState(() {
          unreadCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 145, 19, 10),
          automaticallyImplyLeading: false, // เอาลูกศรย้อนกลับออก
          title: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Image.asset(
                  'assets/icons/homelogo.png',
                  height: 28,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              // ใช้ Expanded เพื่อให้ TextField ขยายเต็มขนาดที่ Container มีให้
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(16, 2, 16, 12),
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        hintText: "Search..."),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Image.asset(
                'assets/icons/homecart.png',
                height: 28,
              )
            ],
          )),
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: CardProduct()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // สีเงา
              blurRadius: 8, // ความเบลอของเงา
              offset: Offset(0, -2), // เลื่อนเงาขึ้นเล็กน้อย
            ),
          ],
        ),
        child: BottomAppBar(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      ImageIcon(
                        AssetImage("assets/icons/home.png"),
                        size: 35,
                        color: colorNoClick,
                      ),
                      Text(
                        "หน้าแรก",
                        style: TextStyle(
                          color: colorNoClick,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      ImageIcon(
                        AssetImage("assets/icons/play.png"),
                        size: 35,
                        color: colorNoClick,
                      ),
                      Text(
                        "วิดีโอ",
                        style: TextStyle(
                          color: colorNoClick,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 100,
              ),
              Stack(
                children: [
                  InkWell(
                    onTap: () async {
                      if (Get.isRegistered<GetNotification>()) {
                        // ✅ ตรวจสอบว่ามี Controller อยู่ไหม
                        await notiController.fetchNotificationData(
                            forceRefresh: true);
                        await Get.to(() => NotificationWidget());
                      } else {
                        print("Controller ไม่ได้ถูกสร้าง");
                      }
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          "assets/chat/notification.svg",
                          height: 35,
                        ),
                        Text(
                          "แจ้งเตือน",
                          style: TextStyle(
                            color: colorNoClick,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 26,
                    child: badges.Badge(
                      badgeContent: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                        ),
                      ),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: Colors.red,
                        shape: badges.BadgeShape.square, // รูปทรง Badge
                        borderRadius: BorderRadius.circular(15),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5.5, vertical: 1),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    getxLogoutController.logout();
                  },
                  child: Column(
                    children: [
                      ImageIcon(
                        AssetImage("assets/icons/profile.png"),
                        size: 35,
                        color: colorNoClick,
                      ),
                      Text(
                        "โปรไฟล์",
                        style: TextStyle(
                          color: colorNoClick,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ClipOval(
        child: Material(
          elevation: 10,
          color: const Color(0xFF811EA1),
          child: InkWell(
            onTap: () {},
            child: SizedBox(
              width: 65,
              height: 65,
              child: Image.asset(
                "assets/icons/centerbotton_mbkmall.png",
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
