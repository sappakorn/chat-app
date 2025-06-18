import 'package:app/controller/notification/get_notification.dart';
import 'package:app/views/pages/chats/select_account.dart';
import 'package:app/views/pages/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GetNotification notificationController = Get.put(GetNotification());
    return Scaffold(
      appBar: AppBar(
        title: Text("การแจ้งเตือน"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ปุ่มย้อนกลับ
          onPressed: () {
            Get.to(() => HomeScreen(), transition: Transition.noTransition);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => SelectAccount());
            },
            icon: Image.asset(
              'assets/icons/herizon.png',
              height: 28,
            ),
          )
        ],
      ),
      body: Obx(() {
        if (notificationController.isLoading.value &&
            notificationController.notifications.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (notificationController.notifications.isEmpty) {
          print("ไม่มีการแจ้งเตือน");
          return Center(child: Text("ไม่มีการแจ้งเตือน"));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!notificationController.isLoading.value &&
                notificationController.hasMore.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              notificationController.fetchNotificationData();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: notificationController.notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == notificationController.notifications.length) {
                return notificationController.hasMore.value
                    ? Padding(
                        padding: const EdgeInsets.all(0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox.shrink();
              }

              var notification = notificationController.notifications[index];

              return Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    color: notification.statusRead == 0
                        ? Colors.red.shade100
                        : Colors.white,
                  ),
                  child: Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(notification.icon),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        notification.message,
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () async {
                        if (notification.type == "CHAT") {
                          await notificationController.fetchNotificationData(forceRefresh: true);
                          await Get.to(() => SelectAccount());
                          
                        } else {
                          await Get.to(() => HomeScreen())?.then((_) {
                             notificationController.fetchNotificationData(forceRefresh: true);
                            notificationController
                                .update(); 
                          });
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
