import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/customer/customer_message.dart';
import 'package:app/views/pages/chats/customers/customer_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CustomerChatProfile extends StatelessWidget {
  const CustomerChatProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _auth = Get.put(AuthController());
    final CustomerMessageController _customerMessage =
        Get.put(CustomerMessageController());
    RxString customerProfile = "".obs;
    RxString customerName = "".obs;
    final imageSupport =
        "https://mbk-storage.sgp1.digitaloceanspaces.com/icons/icon_user.png";
    return Obx(() {
      if (_customerMessage.messagesList.isEmpty) {
        return Container(
          height: 1,
        );
      } else {
        customerProfile.value = _auth.customerImage.value;
        customerName.value = _auth.customerName.value;

        return InkWell(
          onTap: () {
            Get.to(() => CustomerMessage());
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 7, 2, 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(customerProfile.value.isEmpty
                      ? imageSupport
                      : customerProfile.value),
                  radius: 25,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.value.isEmpty
                          ? "CustomerName"
                          : customerName.value,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
