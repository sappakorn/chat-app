import 'package:app/constants/config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/models/product.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentPage = 1.obs;
  final int maxProducts = 100; // จำกัดขนาดของ products
  final int limit = 10; // โหลด 10 รายการต่อหน้า

  @override
  void onInit() {
    super.onInit();
    _getProduct(); // โหลดข้อมูลหน้าแรก
  }

  Future<void> _getProduct({bool isLoadMore = false}) async {
    if (isLoading.value || isMoreLoading.value) return; // ป้องกันการโหลดซ้ำ

    try {
      if (isLoadMore) {
        isMoreLoading.value = true;
      } else {
        isLoading.value = true;
      }

      final res = await http.get(
        Uri.parse('${Configs.apiServerUrl}/product/'),
        headers: {
          "Content-Type": "application/json",
          "X-Limit": limit.toString(),
          "X-Page": currentPage.value.toString(),
        },
      );

      if (res.statusCode == 200) {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        final data = resJson['result']['data'];

        if (data is List) {
          var newProducts = data.map((item) => Product.fromJson(item)).toList();

          if (isLoadMore) {
            products.addAll(newProducts); // เพิ่มข้อมูลใหม่
          } else {
            products.assignAll(newProducts); // แทนที่ข้อมูล
          }

          // ป้องกัน products ใหญ่เกินไป
          if (products.length > maxProducts) {
            products.removeRange(0, products.length - maxProducts);
          }

          if (newProducts.isNotEmpty) {
            currentPage.value++; // ไปหน้าถัดไป
          }
        }
      }
    } catch (error) {
      print("Error: $error");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void loadMoreProducts() {
    if (!isMoreLoading.value && products.length < maxProducts) {
      _getProduct(isLoadMore: true);
    }
  }

  @override
  void onClose() {
    products.clear(); // ล้างข้อมูลเมื่อตัว Controller ถูกทำลาย
    super.onClose();
  }
}
