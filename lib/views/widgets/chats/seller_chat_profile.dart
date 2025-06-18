import 'package:app/controller/auth/auth.dart';
import 'package:app/views/pages/chats/seller/seller_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SellerChatProfile extends StatelessWidget {
  const SellerChatProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _auth = Get.put(AuthController());

    final imageSupport =
        "https://mbk-storage.sgp1.digitaloceanspaces.com/icons/icon_user.png";
    print(_auth.sellerStatus.runtimeType);
    print(_auth.sellerStatus.toString());
    return Obx(() {
      // ignore: unrelated_type_equality_checks
      if (_auth.sellerStatus == "null") {
        return Container(
          height: 1,
        );
      } else {
        final name = _auth.sellerName.value;
        final image = _auth.sellerImage.value;
        final imageUrl = (image == "") ? imageSupport : image;
        return InkWell(
          onTap: () {
            Get.to(() => SellerMessage());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        imageUrl.isEmpty
                            ? imageSupport
                            : imageUrl),
                    radius: 25,
                  ),
                  Positioned(
                      bottom: -1,
                      right: 0,
                      child: SvgPicture.asset(
                        'assets/chat/logochatshop.svg',
                        height: 18,
                        width: 18,
                      )),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : "My Shop",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ],
          ),
        );
      }
    });
  }
}
