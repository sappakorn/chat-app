import 'package:app/views/pages/chats/service_chat/select_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CustomerWithMbkmallWidget extends StatelessWidget {
  const CustomerWithMbkmallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => SelectService());
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset('assets/chat/Frame38142.svg'),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
