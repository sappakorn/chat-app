import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/controller/chats/new_chat_with_seller.dart';

class ProductWidget extends StatelessWidget {
  const ProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final NewChatWithSeller newChat = Get.put(NewChatWithSeller());

    final String productName = arguments['product_name'] ?? 'No Name';
    final String productImage = arguments['product_image'] ?? '';
    final String productPrice = arguments['product_price'] ?? '';
    final String productDescription = arguments['product_description'] ?? '';
    final String sellerId = arguments['seller_id'] ?? '';
    final String productId = arguments['product_id'] ?? '';
    final String sellerName = arguments['seller_name'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: productImage,
              height: 350.0,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error, size: 50),
            ),
            SizedBox(height: 10),
            Text(
              productName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              productDescription,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price: $productPrice',
                  style: TextStyle(fontSize: 18, color: Colors.orange),
                ),
                IconButton(
                  onPressed: () {
                    newChat.newCustomerWithSeller(
                      sellerId,
                      productId,
                      productName,
                      sellerName,
                    );
                  },
                  icon: Image.asset(
                    "assets/icons/messenger.png",
                    color: Colors.black,
                    height: 20,
                    width: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
