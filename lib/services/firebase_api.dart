import 'dart:convert';
import 'dart:io';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/mark_as_read.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class FirebaseApi extends GetxController {
  final _firebasemessaging = FirebaseMessaging.instance;
  final AuthController _authController = Get.put(AuthController());
  final NotificationService _notification = Get.put(NotificationService());
  final MarkAsRead markAsRead = Get.put(MarkAsRead());
  RxInt unRead = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(markAsRead.updateCountRead, (value) {
      unRead.value = value;
    });
  }

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static late AndroidNotificationChannel channel;
  static AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  Future<void> initNotification() async {
    try {
      await initFlutterLocalNotifications();

      // สำคัญ: ต้องลงทะเบียน background handler ก่อน
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // รับข้อความเมื่อแอพอยู่ใน foreground    RemoteMesssage คือ ข้อมูลที่ได้รับจาก FCM
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('================== FOREGROUND MESSAGE ==================');
          print('title: ${message.data['title']}');
          print('body: ${message.data['body']}');
          print('image: ${message.data['image']}');
          print('action_url: ${message.data['action_url']}');
        }
        // แสดงการแจ้งเตือนทันทีที่ได้รับข้อมูล
        _showLocalNotification(message.data);
      });

      // จัดการเมื่อแอพอยู่ใน foreground และมีการคลิกที่ notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('================ NOTIFICATION CLICKED ================');
          print('RemoteMessage: ${message.toString()}');
          print('Data: ${message.data}');
          print('URL to open: ${message.data['url']}');
          print('====================================================');
        }

        final url = message.data['url'];
        if (url != null && url.isNotEmpty) {
          _handleNotificationClick(url);
        }
      });

      if (Platform.isIOS) {
        // ขอสิทธิ์การแจ้งเตือนสำหรับ iOS
        NotificationSettings settings =
            await _firebasemessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          throw Exception('การขอสิทธิ์การแจ้งเตือนถูกปฏิเสธ');
        }

        // รอให้ได้ APNS token ด้วย Future.delayed
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          await Future.delayed(Duration(seconds: 2));
          apnsToken = await _firebasemessaging.getAPNSToken();
          if (apnsToken != null) {
            if (kDebugMode) {
              print('APNS Token: $apnsToken');
            }
            break;
          }
        }

        if (apnsToken == null) {
          throw Exception('ไม่สามารถรับ APNS token ได้');
        }
      }

      // fetch FCM token หลังจากได้ APNS token แล้ว
      String? fcmToken = await _firebasemessaging.getToken();
      if (fcmToken != null) {
        if (kDebugMode) {
          print('FCM Token: $fcmToken');
          _authController.saveFCMtoken(fcmToken);
        }
      } else {
        throw Exception('ไม่สามารถรับ FCM token ได้');
      }

      // ตั้งค่า foreground notification handling
      await _firebasemessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
      rethrow;
    }
  }

  // แจ้งเตือนในแอพ
  Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('Showing local notification with data: $data');
      }

      // API Count status read
      int unread = await _notification.getCountNotification();
      unRead.value = unread;
      FlutterAppBadger.updateBadgeCount(unread);
      //

      // สร้าง Android Channel
      const androidChannel = AndroidNotificationDetails(
        'high_importance_channel', // channel Id
        'High Importance Notifications', // channel Name
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      // สร้าง iOS Channel
      const iosChannel = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // รวม channel settings
      const notificationDetails = NotificationDetails(
        android: androidChannel,
        iOS: iosChannel,
      );

      // แสดงการแจ้งเตือน
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond, // notification id
        data['title'] ?? 'No Title', // title
        data['body'] ?? 'No Body', // body
        notificationDetails,
        payload: jsonEncode(data), // เก็บข้อมูลทั้งหมดไว้ใน payload
      );

      if (kDebugMode) {
        print('Local notification shown successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing local notification: $e');
      }
    }
  }

  // ต้องเพิ่มการ initialize local notifications ให้ถูกต้อง
  Future<void> initFlutterLocalNotifications() async {
    try {
      // สร้าง Android Channel
      channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );

      // สร้าง channel ใน Android device
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // ขอสิทธิ์สำหรับ iOS
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // ตั้งค่า initialization
      await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: const DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification clicked with payload: ${response.payload}');
          }
          if (response.payload != null) {
            final data = jsonDecode(response.payload!);
            if (data['url'] != null) {
              _handleNotificationClick(data['url']);
            }
          }
        },
      );

      if (kDebugMode) {
        print('Flutter Local Notifications initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Flutter Local Notifications: $e');
      }
    }
  }

  void _handleNotificationClick(String url) {
    // Implementation of _handleNotificationClick method
  }
}

// ย้าย handler ไปไว้ด้านนอก class และเพิ่ม @pragma
@pragma(
    'vm:entry-point') // คือการบอกว่าฟังก์ชัน _firebaseMessagingBackgroundHandler นี้จะถูกเรียกใช้จาก background isolate
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ต้อง initialize Firebase ก่อน
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ต้อง initialize local notifications ด้วยตัวเองเพราะอยู่ นอก class
  await initializeLocalNotificationsForBackground();

  if (kDebugMode) {
    print('================ BACKGROUND MESSAGE ================');
    print('Data: ${message.data}');
  }

  try {
    // แสดงการแจ้งเตือนใน background
    const androidChannel = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );

    const iosChannel = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidChannel,
      iOS: iosChannel,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // แสดงการแจ้งเตือน background
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      message.data['title'] ?? 'No Title',
      message.data['body'] ?? 'No Body',
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    if (kDebugMode) {
      print('Background notification shown successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error showing background notification: $e');
    }
  }
}

// เพิ่มฟังก์ชันสำหรับ initialize local notifications ใน background
@pragma('vm:entry-point')
Future<void> initializeLocalNotificationsForBackground() async {
  // API Count status read
  final NotificationService notification = Get.put(NotificationService());
  RxInt unRead = 0.obs;

  int unreadCount = await notification.getCountNotification();
  unRead.value = unreadCount;
  FlutterAppBadger.updateBadgeCount(unreadCount);
  //

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // สร้าง Android Channel
  const androidChannel = AndroidNotificationChannel(
    'high_importance_channel', // channel Id
    'High Importance Notifications', // channel Name
    importance: Importance.max, // สำคัญสุด
  );

  // สร้าง channel ใน Android device
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // ขอสิทธิ์ ios
  await flutterLocalNotificationsPlugin.initialize(
    //
    const InitializationSettings(
      android: AndroidInitializationSettings(
          '@mipmap/ic_launcher'), // ต้องใส่ icon ที่มีในโปรเจค
      iOS: DarwinInitializationSettings(), // กดเข้าไปดู setting
    ),
  );
}
