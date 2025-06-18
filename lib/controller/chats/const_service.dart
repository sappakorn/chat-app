import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/models/chat/service_type.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConstService extends GetxController {
  var types = <Types>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  var limit = 4.obs;

  @override
  void onInit() {
    super.onInit();
    _getServiceType();
  }

  void _getServiceType() async {
    try {
      isLoading.value = true;

      final res = await http.get(
        Uri.parse('${Configs.apiServerUrl}/constant/service-type'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final resutf8 = utf8.decode(res.bodyBytes);
        final resjson = jsonDecode(resutf8);

        final message = resjson['message'];
        final result = resjson['result'];
        print(message);

        if (result is List) {
          types.clear();
          for (var itme in result) {
            types.add(Types.fromJson(itme));
          }
        } else {
          print("result not List");
        }
      } else {
        final resutf8 = utf8.decode(res.bodyBytes);
        final resjson = jsonDecode(resutf8);
        final message = resjson['message'];
        print(message);
      }
    } catch (error) {
      print("catch");
      print(error);
    } finally {
      isLoading.value = false;
    }
  }
}
