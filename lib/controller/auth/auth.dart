// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var authToken = ''.obs;
  var customerId = ''.obs;
  var customerImage = ''.obs;
  var customerName = ''.obs;

  var sellerName = ''.obs;
  var sellerStatus = ''.obs;
  var sellerId = ''.obs;
  var sellerImage = ''.obs;

  var fmcToken = ''.obs;

  @override
  void onInit() {
    loadAuthData();
    loadMeData();
    super.onInit();
  }

  Future<void> loadAuthData() async {
    authToken.value = await _storage.read(key: 'authToken') ?? '';
    customerId.value = await _storage.read(key: 'customerId') ?? '';
    customerImage.value = await _storage.read(key: 'customerImage') ?? '';
    customerName.value = await _storage.read(key: 'customerName') ?? '';
  }

  Future<void> saveAuthData(
      String token, String id, String img, String name) async {
    await _storage.write(key: 'authToken', value: token);
    await _storage.write(key: 'customerId', value: id);
    await _storage.write(key: 'customerImage', value: img);
    await _storage.write(key: 'customerName', value: name);

    authToken.value = token;
    customerId.value = id;
    customerImage.value = img;
    customerName.value = name;
  }

  Future<void> loadFCMToken() async {
    fmcToken.value = await _storage.read(key: 'fcmToken') ?? '';
  }

  Future<void> saveFCMtoken(String fcmToken) async {
    await _storage.write(key: 'fcmToken', value: fcmToken);
    fmcToken.value = fcmToken;
  }

  Future<void> loadMeData() async {
    sellerName.value = await _storage.read(key: 'sellerName') ?? '';
    sellerStatus.value = await _storage.read(key: 'sellerStatus') ?? '';
    sellerId.value = await _storage.read(key: 'sellerId') ?? '';
    sellerImage.value = await _storage.read(key: 'sellerImage') ?? '';
  }

  Future<void> saveMeData(String seller_name, String seller_status,
      String seller_id, String seller_image) async {
    await _storage.write(key: 'sellerName', value: seller_name);
    await _storage.write(key: 'sellerStatus', value: seller_status.toString());
    await _storage.write(key: 'sellerId', value: seller_id);
    await _storage.write(key: 'sellerImage', value: seller_image);

    sellerName.value = seller_name;
    sellerStatus.value = seller_status.toString();
    sellerId.value = seller_id;
    sellerImage.value = seller_image;
  }

  
}
