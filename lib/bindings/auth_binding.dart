import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/auth/me.dart';
import 'package:app/controller/chats/const_service.dart';
import 'package:app/controller/chats/mark_as_read.dart';
import 'package:app/services/firebase_api.dart';
import 'package:app/services/notification_service.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ใช้ permanent เฉพาะ controllers ที่จำเป็นจริงๆ
    Get.put<AuthController>(AuthController(), permanent: true);

    // controllers อื่นๆ ให้ใช้ lazyPut แทน
    Get.lazyPut<Me>(() => Me());
    Get.lazyPut<ConstService>(() => ConstService());
    Get.lazyPut<MarkAsRead>(() => MarkAsRead());
    Get.lazyPut<FirebaseApi>(() => FirebaseApi());
    Get.lazyPut<NotificationService>(() => NotificationService());
  }
}
