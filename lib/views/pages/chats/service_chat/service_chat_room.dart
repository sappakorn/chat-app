import 'dart:async';
import 'dart:io';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/const_service.dart';
import 'package:app/services/file_upload_service.dart';
import 'package:app/services/pin_chat.dart';
import 'package:app/views/pages/chats/service_chat/select_service.dart';
import 'package:app/views/widgets/image_preview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // intl package ช่วยในการจัดรูปแบบวันที่
import 'package:image/image.dart' as img;

class ServiceChatRoom extends StatefulWidget {
  final String chatRoomId;
  final String serviceType;
  const ServiceChatRoom({
    super.key,
    required this.chatRoomId,
    required this.serviceType,
  });

  @override
  State<ServiceChatRoom> createState() => _ServiceChatRoomState();
}

class _ServiceChatRoomState extends State<ServiceChatRoom> {
  late final DatabaseReference databaseRef;

  late String chatRoom = widget.chatRoomId;
  late String serviceType = widget.serviceType;

  final TextEditingController _messageController = TextEditingController();

  final FileUploadService _fileUploadService = Get.put(FileUploadService());
  final AuthController _authControler = Get.put(AuthController());
  final PinChatService _pinChatService = Get.put(PinChatService());

  List<Map<String, dynamic>> _messages = [];

  late StreamSubscription _messagesSubscription;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance
        .ref()
        .child('chats/$serviceType/$chatRoom/messages/');
    _fetchMessages();
  }

  Future<void> _pickerImage() async {
    final picker = ImagePicker();
    final XFile? pickerFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickerFile != null) {
      setState(() {
        _imageFile = File(pickerFile.path);
      });
      _showImagePreview(_imageFile!);
      await _resizeImage(_imageFile!);
    }
  }

  Future<void> _resizeImage(File imageFile) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image != null) {
      int width = (image.width * 0.5).toInt();
      int height = (image.height * 0.5).toInt();
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);
      List<int> resizedBytes = img.encodeJpg(resizedImage);
      File resizedFile =
          File(imageFile.path.replaceAll('.jpg', '_resized.jpg'));
      await resizedFile.writeAsBytes(resizedBytes);
      setState(() {
        _imageFile = resizedFile;
      });
    }
  }

  Future<void> _sendImage() async {
    if (_imageFile != null) {
      try {
        String fileName = _imageFile!.path.split('/').last;
        String pathName = 'chats/${widget.chatRoomId}';
        String imageUrl = await _fileUploadService.uploadFile(
            _imageFile!, fileName, pathName);
        if (imageUrl.isNotEmpty) {
          _sendMessageImage(imageUrl);
          setState(() {
            _imageFile = null;
          });
        } else {
          print('Failed to upload image');
        }
      } catch (e) {
        print('Error sending image: $e');
      }
    }
  }

  Future<void> updateStatusRead() async {
    final chatId = widget.chatRoomId;
    final database =
        FirebaseDatabase.instance.ref('chats/$serviceType/$chatId/messages');

    final snapshot = await database.get(); // ดึงข้อมูลทั้งหมด

    if (snapshot.exists) {
      // ถ้ามีข้อมูล
      Map<dynamic, dynamic> messages = snapshot.value
          as Map<dynamic, dynamic>; // แปลงข้อมูลเป็น Map<dynamic, dynamic>

      messages.forEach((key, value) async {
        // วนลูปด้วย key , และ เก็บข้อมูลไว้ใน value
        if (value['sender'] == 'mbkmall') {
          await database.child(key).update({"statusRead": 0});
        }
      });
    }
  }

  void _fetchMessages() {
    try {
      _messagesSubscription =
          databaseRef.orderByChild('timestamp').onValue.listen((event) {
        final data = event.snapshot.value;
        // Check if data is null or not a Map
        if (data == null || data is! Map<dynamic, dynamic>) {
          if (mounted) {
            setState(() {
              _messages = [];
            });
          }
          return;
        }

        final List<Map<String, dynamic>> loadedMessages = [];
        data.forEach((messageId, messageData) {
          print(messageId);
          loadedMessages.add({
            'id': messageId,
            'text': messageData['text'],
            'sender': messageData['sender'],
            'imageUrl': messageData['imageUrl'],
            'actionUrl': messageData['actionUrl'],
            'actionId': messageData['actionId'],
            'timestamp': int.tryParse(messageData['timestamp'].toString()) ?? 0,
          });
        });

        // Sort messages by timestamp from newest to oldest
        loadedMessages.sort((a, b) {
          return b['timestamp'].compareTo(a['timestamp']);
        });

        // Update the state only if widget is still mounted
        if (mounted) {
          setState(() {
            _messages = loadedMessages;
          });
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        Get.to(() => ConstService());
      });
      return;
    }
  }

  @override
  void dispose() {
    // Cancel the listener to avoid memory leaks
    _messagesSubscription.cancel();
    super.dispose();
  }

  void _sendMessage() {
    final data = {
      'text': _messageController.text,
      'sender': "customer",
      'statusRead': 1,
      "actionUrl": "",
      "actionId": "",
      "imageUrl": "",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    /* 
    _notification  mbkmall userId 
      reciver = "mbkmall";
      reciverId = userId ;
    */

    databaseRef.push().set(data);
    _messageController.clear();
  }

  void _sendMessageImage(String imageUrl) {
    final data = {
      'text': "",
      'sender': "customer",
      'statusRead': 1,
      "actionUrl": "",
      "actionId": "",
      "imageUrl": imageUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    databaseRef.push().set(data);
    _messageController.clear();
  }

  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePreview(
          imageFile: image,
          onSend: () {
            // ส่งฟังก์ชันไปทำงานหน้า ImagepPreview
            Navigator.pop(context); // ปิด Modal
            _sendImage(); // ส่งรูป
          },
          onCancel: () {
            Navigator.pop(context); // ปิด Modal
            setState(() {
              _imageFile = null; // ล้างรูปภาพที่เลือก
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          "ศูนย์ช่วยเหลือ",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => SelectService());
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: _buildMessageList(),
            ),
          ),
          Container(
            color: Colors.white,
            height: 70,
            child: _buildMessageInput(),
          ),
          Container(
            color: Colors.white,
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: _messages.length,
      reverse: true,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final senderType = message['sender'];

        return Column(
          crossAxisAlignment: senderType == 'customer'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message['text'] != null && message['text']!.isNotEmpty)
              Align(
                alignment: senderType == 'customer'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: senderType == 'customer'
                        ? Colors.greenAccent[100]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: senderType == 'customer'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: senderType == 'customer'
                              ? Colors.black
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              message['timestamp']),
                        ),
                        style:
                            const TextStyle(fontSize: 13.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            if (message['imageUrl'] != null && message['imageUrl']!.isNotEmpty)
              Align(
                alignment: senderType == 'customer'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          message['imageUrl'] ?? '',
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              message['timestamp']),
                        ),
                        style:
                            const TextStyle(fontSize: 13.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _pickerImage();
            },
            icon: SvgPicture.asset('assets/chat/image.svg'),
          ),
          Expanded(
            child: SizedBox(
              child: TextField(
                style: TextStyle(fontSize: 15.0),
                controller: _messageController,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.blueGrey),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_messageController.text != "") {
                _sendMessage();
              }
              if (_imageFile != null) {
                _sendImage();
              }
            },
            icon: SvgPicture.asset('assets/chat/send.svg'),
          ),
        ],
      ),
    );
  }
}
