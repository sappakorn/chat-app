import 'dart:io';
import 'package:app/controller/auth/auth.dart';
import 'package:app/controller/chats/mark_as_read.dart';
import 'package:app/controller/chats/chat_notification.dart';
import 'package:app/services/file_upload_service.dart';
import 'package:app/services/pin_chat.dart';
import 'package:app/views/pages/chats/seller/seller_message.dart';
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

class SellerChatRoom extends StatefulWidget {
  final String chatRoom;
  final String customerIamge;
  final String customerName;
  final String sellerId;
  final String customerId;

  const SellerChatRoom({
    super.key,
    required this.chatRoom,
    required this.customerIamge,
    required this.customerName,
    required this.sellerId,
    required this.customerId,
  });

  @override
  State<SellerChatRoom> createState() => _SellerChatRoomState();
}

class _SellerChatRoomState extends State<SellerChatRoom> {
  late final DatabaseReference databaseReference;
  late StreamSubscription _messagesSubscription;

  late String chatRoomId = widget.chatRoom;
  late String sellerId = widget.sellerId;
  late String customerId = widget.customerId;
  late String customerName = widget.customerName;

  final TextEditingController _messageController = TextEditingController();

  final NotificationController _notification =
      Get.put(NotificationController());
  final FileUploadService fileUploadService = Get.put(FileUploadService());
  final PinChatService pinChatService = Get.put(PinChatService());
  final AuthController _authControlle = Get.put(AuthController());
  final MarkAsRead _markAsRead = Get.put(MarkAsRead());

  List<Map<String, dynamic>> _messages = []; // เก็บข้อความในแชท

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    print(chatRoomId);
    databaseReference = FirebaseDatabase.instance
        .ref()
        .child('chats/$sellerId/$chatRoomId/messages/');
    _fetchMessages();
    updateStatusRead();
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
        String pathName = 'chats/${widget.chatRoom}';
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
    final chatId = widget.chatRoom;
    final DatabaseReference database =
        FirebaseDatabase.instance.ref('chats/$sellerId/$chatId/messages');

    final snapshot = await database.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> messages = snapshot.value as Map<dynamic, dynamic>;

      messages.forEach((key, value) async {
        if (value['sender'] == 'customer') {
          await database.child(key).update({"statusRead": 0});
        }
      });
    }
    _markAsRead.markAsRead(chatId);
  }

  void _fetchMessages() {
    _messagesSubscription =
        databaseReference.orderByChild('timestamp').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
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
          'timestamp': messageData['timestamp'],
        });
      });
      // เรียงลำดับเวลาจากน้อยไปมาก
      loadedMessages.sort((a, b) {
        return b['timestamp'].compareTo(a['timestamp']);
      });

      if (mounted) {
        setState(() {
          _messages = loadedMessages;
        });
      }
    });
  }

  void _sendMessage() {
    final data = {
      'text': _messageController.text,
      'sender': "seller",
      'statusRead': 1,
      "actionUrl": "",
      "actionId": "",
      "imageUrl": "",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final sellerName = _authControlle.sellerName.value;
    final sellerImage = _authControlle.sellerImage.value;

    // API chat-notification
    _notification.chatNotification(
      "customer", // reciver
      customerId, // reciverId
      sellerName,
      _messageController.text,
      sellerImage,
      chatRoomId,
    );

    databaseReference.push().set(data);
    _messageController.clear();
  }

  @override
  void dispose() {
    // Cancel the listener to avoid memory leaks
    _messagesSubscription.cancel();
    super.dispose();
  }

  void _sendMessageImage(String imageUrl) {
    final data = {
      'text': "",
      'sender': "seller",
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
                _imageFile = null; // ล้างรูปภาพที่เลือก
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(customerName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // ปุ่มย้อนกลับ
          onPressed: () {
            Get.to(() => SellerMessage(), transition: Transition.noTransition);
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
          crossAxisAlignment: senderType == 'seller'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message['text'] != null && message['text']!.isNotEmpty)
              Align(
                alignment: senderType == 'seller'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: senderType == 'seller'
                        ? Colors.greenAccent[100]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: senderType == 'seller'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: senderType == 'seller'
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
                alignment: senderType == 'seller'
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
          pinChatService.pinChat(widget.chatRoom);
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
