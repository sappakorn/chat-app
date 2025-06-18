// ignore: depend_on_referenced_packages
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/customer/customer_message.dart';
import 'package:app/controller/chats/seller/seller_message.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GetxLogoutController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var authToken = ''.obs;
  var customerId = ''.obs;
  var customerImage = ''.obs;
  var customerName = ''.obs;

  var sellerName = ''.obs;
  var sellerStatus = ''.obs;
  var sellerId = ''.obs;
  var sellerImage = ''.obs;

  Future<void> logout() async {
    await clearAuthData();
    print("logout success");
    Get.to(() => LoginPage());
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'customerId');
    await _storage.delete(key: 'customerImage');
    await _storage.delete(key: 'customerName');

    await _storage.delete(key: 'sellerName');
    await _storage.delete(key: 'sellerStatus');
    await _storage.delete(key: 'sellerId');
    await _storage.delete(key: 'sellerImage');

    authToken.value = '';
    customerImage.value = '';
    customerId.value = '';
    customerName.value = '';

    sellerId.value = '';
    sellerImage.value = '';
    sellerName.value = '';
    sellerStatus.value = 'false';
    print("clear auth data success");


    clearController();
  }

  void clearController() {
    try {
      Get.delete<CustomerMessageController>();
      Get.delete<SellerMessageController>();
      Get.delete<AuthController>();
    } catch (e) {
      print("❌ Error clearing models: $e");
    }
  }
}
