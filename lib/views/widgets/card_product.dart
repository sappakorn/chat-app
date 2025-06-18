import 'package:app/controller/products/product.dart';
import 'package:app/views/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardProduct extends StatelessWidget {
  final ProductController productController = Get.put(ProductController());
  final ScrollController _scrollController = ScrollController();

  CardProduct({Key? key}) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        productController.loadMoreProducts(); // โหลดข้อมูลเพิ่มเมื่อถึงล่างสุด
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Obx(() {
        if (productController.isLoading.value && productController.products.isEmpty) {
          return Center(child: CircularProgressIndicator()); // โหลดหน้าจอแรก
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: _scrollController, // ใช้ ScrollController
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: productController.products.length,
                itemBuilder: (context, index) {
                  final product = productController.products[index];

                  return InkWell(
                    onTap: () {
                      Get.to(() => ProductWidget(), arguments: {
                        'product_id': product.id,
                        'product_name': product.name,
                        'product_image': product.image_url,
                        'product_price': product.price,
                        'product_description': product.description,
                        'seller_id': product.seller_id,
                        'seller_name': product.seller_name,
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            product.image_url,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.orange),
                              Text(
                                '${product.count_star} | ขายแล้ว 5125 ชิ้น',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '฿${product.price}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (productController.isMoreLoading.value)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()), // แสดง Loading ตอนโหลดเพิ่ม
              ),
          ],
        );
      }),
    );
  }
}
