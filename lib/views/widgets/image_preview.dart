import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File imageFile;
  final VoidCallback onSend; // ฟังก์ชันเมื่อกดส่ง
  final VoidCallback onCancel; // ฟังก์ชันเมื่อกดยกเลิก

  const ImagePreview({
    Key? key,
    required this.imageFile,
    required this.onSend,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // แสดงรูปภาพที่เลือก
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: 500, // กำหนดขนาดให้เหมาะสม
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          // ปุ่มกด "ส่งภาพ" และ "ยกเลิก"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // background color
                  foregroundColor: Colors.white, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: onCancel,
                child: Text(
                  'ยกเลิก',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // background color
                  foregroundColor: Colors.white, // text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: onSend,
                child: Text('ส่งรูปภาพ', style: TextStyle(fontSize: 20)),
              )
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
