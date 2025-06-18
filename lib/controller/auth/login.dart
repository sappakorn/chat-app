import 'dart:convert';
import 'package:app/controller/auth/me.dart';
import 'package:app/controller/auth/save_device_token.dart';
import 'package:app/controller/products/product.dart';
import 'package:app/views/pages/home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:get/get.dart';

class AuthLoginService {
  final String baseUrl = '${Configs.apiServerUrl}/auth/login';
  final AuthController _authController = Get.put(AuthController());
  final SaveDeviceToken saveDeviceToken = Get.put(SaveDeviceToken());
  final Me meService = Get.put(Me());

  Future<Map<String, dynamic>> login({
    required String telephone,
    required String password,
  }) async {
    Get.lazyPut<ProductController>(() => ProductController());
    final Uri url = Uri.parse(baseUrl);

    try {
      final Map<String, dynamic> payload = {
        'telephone': telephone,
        'password': password,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final resutf8 = utf8.decode(response.bodyBytes);
      final res = jsonDecode(resutf8);

      if (response.statusCode == 200) {
        final result = res['result'];
        final customer = result['customer'];
        final token = result['token'];
        final id = customer['id'];
        final img = customer['image_profile'];

        // print("imageProfileCustomer");
        // print(img);
        final name = customer['name']; // เรียกใช้ชื่อของลูกค้า

        await _authController.saveAuthData(
            token, id, img, name); // save auth data
        meService.getUser(); // get customer data and seller data

        String deviceToken =
            _authController.fmcToken.value; // read device token
        saveDeviceToken.saveDeviceToken(
            deviceToken, token); // save device token

        return {
          'success': true,
          'data': customer,
        };
      } else {
        // ข้อผิดพลาดจาก API
        final error = jsonDecode(response.body);
        //  print(error);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

class LoginController extends GetxController {
  final AuthLoginService authLoginService = AuthLoginService();
  var isLoading = false.obs;
  void login(String telephone, String password) async {
    isLoading(true);

    final result =
        await authLoginService.login(telephone: telephone, password: password);
    isLoading(false);

    if (result['success']) {
      Get.offAll(() => HomeScreen(), transition: Transition.circularReveal);
    } else {
      Get.snackbar('Error', result['message'] ?? 'An error occurred');
    }
  }
}
