import 'dart:io';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/mark_as_read.dart';
import 'package:app/controller/chats/chat_notification.dart';
import 'package:app/services/file_upload_service.dart';
import 'package:app/services/pin_chat.dart';
import 'package:app/views/pages/chats/customers/customer_message.dart';
import 'package:app/views/widgets/image_preview.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CustomerChatRoom extends StatefulWidget {
  final String chatRoomId; // รับค่า chatRoomId ที่คลิกมาก่อนหน้านี้
  final String sellerId; // รับค่า SellerId คนที่คเราจะคุย
  final String sellerName;

  const CustomerChatRoom({
    super.key,
    required this.chatRoomId,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<CustomerChatRoom> createState() => _CustomerChatRoomState();
}

class _CustomerChatRoomState extends State<CustomerChatRoom> {
  late final DatabaseReference
      databaseReference; // DatabaseReference สำหรับเชื่อมต่อ Firebase Realtime Database
  late String chatRoom = widget.chatRoomId; // สร้างตัวแปร ที่เปลี่ยนแปลงค่าได้
  late String sellerId = widget.sellerId;
  late String sellerName = widget.sellerName;
  final TextEditingController _messageController =
      TextEditingController(); // Controller กล่องข้อความ

  // API
  final PinChatService pinChatService =
      Get.put(PinChatService()); // เรียกใช้ Api pinChat
  final FileUploadService fileUploadService =
      Get.put(FileUploadService()); // เรียกใช้ Api fileUpload
  final NotificationController _notification =
      Get.put(NotificationController()); // เรียนใช้ Api Notification
  final AuthController _authController = Get.put(AuthController());
  final MarkAsRead _markAsRead = Get.put(MarkAsRead());

  File? _imageFile; // ตัวแปรที่เก็บข้อมูลรูปภาพ

  List<Map<String, dynamic>> _messages =
      []; // List ที่เอาไว้เก็บข้อความจาก Firebase Realtime Database

  late StreamSubscription _messagesSubscription;
  // ฟังก์ชันที่เรียกใช้งานคครั้งแรกเมื่อเปิดหน้านี้
  @override
  void initState() {
    super.initState();
    databaseReference = FirebaseDatabase.instance.ref().child(
        'chats/$sellerId/$chatRoom/messages/'); // กำหนดPathที่จะเข้าถึงข้อมูล Realtime Database
    _fetchMessage(); // ดึงข้อมูลจาก firebase database
    updateStatusRead();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    //Xfile คือ ตัวแปรที่เก็บข้อมูลรูปภาพ
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // เลือกรูปจาก gallery
    if (pickedFile != null) {
      // ถ้าไม่ใช้ค่าว่าง ให้ทำการเก็บข้อมูลรูปภาพไว้ที่ตัวแปร _imageFile
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _showImagePreview(_imageFile!);
      await _resizeImage(_imageFile!); // ย่อขนาดรูปภาพ
    }
  }

  Future<void> _resizeImage(File imageFile) async {
    img.Image? image = img.decodeImage(
        imageFile.readAsBytesSync()); // แปลง ไฟล์ ก่อนที่จะอ่านไฟล์

    if (image != null) {
      int width = (image.width * 0.5).toInt();
      int height = (image.height * 0.5).toInt();
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height); // ย่อขนาดรูปภาพ
      List<int> resizedBytes = img.encodeJpg(resizedImage); // แปลงเป็น jpg
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
        String imageUrl =
            await fileUploadService.uploadFile(_imageFile!, fileName, pathName);
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
    final DatabaseReference database =
        FirebaseDatabase.instance.ref('chats/$sellerId/$chatId/messages');

    final snapshot = await database.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> messages = snapshot.value as Map<dynamic, dynamic>;

      messages.forEach((key, value) async {
        if (value['sender'] == 'seller') {
          await database.child(key).update({"statusRead": 0});
        }
      });
    }
    _markAsRead.markAsRead(chatId);
  }

  void _fetchMessage() {
    try {
      _messagesSubscription =
          databaseReference.orderByChild('timestamp').onValue.listen((event) {
        final data = event.snapshot.value;
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

        loadedMessages.sort((a, b) {
          return b['timestamp'].compareTo(a['timestamp']);
        });
        if (mounted) {
          setState(() {
            _messages = loadedMessages;
          });
        }
      });
    } catch (error) {
      setState(() {
        Get.to(() => CustomerMessage());
      });
      return;
    }
  }

  @override
  void dispose() {
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

    String customerName = _authController.customerName.value;
    String customerImage = _authController.customerImage.value;

    // API chat-notification
    _notification.chatNotification(
      "seller", // reciver
      sellerId, // reciverId
      customerName,
      _messageController.text,
      customerImage,
      chatRoom,
    );

    databaseReference.push().set(data);
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
    databaseReference.push().set(data);
    _messageController.clear();
  }

  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePreview(
          imageFile: image,
          onSend: () {
            Navigator.pop(context); // ปิด Modal
            _sendImage(); // ส่งรูป
          },
          onCancel: () {
            Navigator.pop(context); // ปิด Modal
            if (mounted) {
              setState(() {
                _imageFile = null;
              });
            }
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
        title: Text(sellerName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ปุ่มย้อนกลับ
          onPressed: () {
            Get.to(() => CustomerMessage(),
                transition: Transition.noTransition);
          },
        ),
        actions: [
          settingChat(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            color: Colors.grey[200],
            child: _buildMessageList(),
          )),
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

            // แสดงรูปภาพแยกออกจาก Container หลัก
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
              _pickImage();
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

  Widget settingChat() {
    return PopupMenuButton<String>(
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeInOut, // การเคลื่อนไหวในช่วงเปิดเมนู
        reverseCurve: Curves.easeIn, // การเคลื่อนไหวเมื่อปิดเมนู
        duration: Duration(milliseconds: 100), // ระยะเวลาในการเคลื่อนไหว
      ),
      color: Colors.white,
      position: PopupMenuPosition.under,
      elevation: 0.5,
      onSelected: (value) {
        if (value == 'PinChat') {
          pinChatService.pinChat(widget.chatRoomId);
        }
      },
      icon: SvgPicture.asset(
        "assets/chat/settingsvg.svg",
        height: 24.0,
        width: 24.0,
      ),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'Profile',
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/chat/profileIcon.svg",
                  height: 24.0,
                  width: 24.0,
                ),
                SizedBox(width: 8),
                Text('Profile'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'ค้นหา',
            child: Row(
              children: [
                Icon(Icons.search),
                SizedBox(width: 8),
                Text('Search'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'PinChat',
            child: Row(
              children: [
                SizedBox(width: 2),
                SvgPicture.asset(
                  "assets/chat/tag.svg",
                  height: 24.0,
                  width: 24.0,
                ),
                SizedBox(width: 8),
                Text('ปักหมุด'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'Settings',
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/chat/turn_off_notify.svg",
                  height: 24.0,
                  width: 24.0,
                ),
                SizedBox(width: 8),
                Text('ปิดการแจ้งเตือน'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'Settings',
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/chat/trash-2.svg",
                  height: 24.0,
                  width: 24.0,
                ),
                SizedBox(width: 8),
                Text('ลบแชท'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'Settings',
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/chat/info.svg",
                  height: 24.0,
                  width: 24.0,
                ),
                SizedBox(width: 8),
                Text('ต้องการความช่วยเหลือ'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
