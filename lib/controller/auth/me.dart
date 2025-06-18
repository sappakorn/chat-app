import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Me extends GetxController {
  final String baseUrl = '${Configs.apiServerUrl}/auth/me';
  final AuthController _authController = Get.put(AuthController());

  Future<void> getUser() async {
    try {
      final String token = _authController.authToken.value;
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Frontend-Token': token,
        },
      );
      final resutf8 = utf8.decode(res.bodyBytes);
      final resjson = jsonDecode(resutf8);
      if (res.statusCode == 200) {
        final result = resjson['result'];
        final seller = result['seller'] ?? "unknow";
        final status = seller['status'];
        final sellerName = seller['name'] ?? "unknow";
        final sellerId = seller['id'];
        final sellerImage = seller['logo_website_image'] ??
            "https://mbk-storage.sgp1.digitaloceanspaces.com/icons/icon_user.png";

        print(" status open shop =" + status.toString());

        if (status == null) {
          print(" status open shop =" + status.toString());
          print("delete Me !");
        }

        await _authController.saveMeData(
            sellerName, status.toString(), sellerId, sellerImage);
        if (kDebugMode) {
          print('loadMeSuccess');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }
}
