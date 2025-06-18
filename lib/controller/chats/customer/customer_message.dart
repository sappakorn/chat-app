import 'dart:convert';
import 'package:app/constants/config.dart';
import 'package:app/controller/auth/auth.dart';
import 'package:app/models/chat/model_customer_message.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CustomerMessageController extends GetxController {
  final AuthController _authController = Get.put(AuthController());

  RxList<ModelCustomerMessage> messagesList = <ModelCustomerMessage>[].obs;
  RxBool isLoading = false.obs;
  Map<String, DatabaseReference> _chatListeners = {};

  @override
  void onInit() {
    super.onInit();
    fetchChatData();
  }

  // ✅ ฟังการเปลี่ยนแปลงของทุก chatId ที่โหลดมาจาก API
  void listenForAllChatUpdates() {
    print("🔍 กำลังฟังทุก chatId...");

    for (var chat in messagesList) {
      String sellerId = chat.sellerId;
      String chatId = chat.chatRoomId;

      // ถ้ามี Listener อยู่แล้ว ไม่ต้องสร้างซ้ำ
      if (_chatListeners.containsKey(chatId)) continue;

      DatabaseReference chatRef = FirebaseDatabase.instance
          .ref()
          .child("chats/$sellerId/$chatId/messages");

      // 🔥 ฟังข้อความใหม่
      chatRef.onChildAdded.listen((event) {
        print("💬 มีข้อความใหม่ในห้อง: $chatId");
        _updateLastMessageAndCount(chatId, sellerId);
      });

      // ✏ ฟังข้อความที่ถูกแก้ไข
      chatRef.onChildChanged.listen((event) {
        print("✏ มีการแก้ไขข้อความในห้อง: $chatId");
        _updateLastMessageAndCount(chatId, sellerId);
      });

      // ✅ เก็บ Reference ไว้
      _chatListeners[chatId] = chatRef;
    }
  }

  // ✅ โหลดข้อมูลจาก API และเริ่มฟัง Firebase
  Future<void> fetchChatData() async {
    isLoading.value = true;
    final String token = _authController.authToken.value;

    try {
      final res = await http.get(
        Uri.parse('${Configs.apiServerUrl}/chat/by-customer'),
        headers: {"X-Frontend-Token": token},
      );

      if (res.statusCode == 200) {
        final resUtf8 = utf8.decode(res.bodyBytes);
        final resJson = jsonDecode(resUtf8);
        List<ModelCustomerMessage> chatList =
            ModelCustomerMessage.listFromJson(resJson['result']);

        messagesList.value = chatList.cast<ModelCustomerMessage>();

        listenForAllChatUpdates();
        _updateAllLastMessagesAndCounts();
      } else {
        print("เกิดข้อผิดพลาด: ${res.statusCode}");
      }
    } catch (error) {
      print('เกิดข้อผิดพลาด: $error');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ดึง `lastMessage` และ `countStatusRead` ของทุกห้อง
  Future<void> _updateAllLastMessagesAndCounts() async {
    for (var chat in messagesList) {
      _updateLastMessageAndCount(chat.chatRoomId, chat.sellerId);
    }
  }

  // ดึง `lastMessage` และ `countStatusRead` ของห้องเดียว
  Future<void> _updateLastMessageAndCount(
      String chatId, String sellerId) async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    int statusRead = 0;
    String lastMessageText = "";
    int lastMessageTimestamp = 0;

    try {
      //ดึงจำนวนข้อความที่ยังไม่ได้อ่าน
      final snapshot = await database
          .child('chats/$sellerId/$chatId/messages')
          .orderByChild('statusRead')
          .equalTo(1)
          .once();

      if (snapshot.snapshot.exists) {
        for (var childSnapshot in snapshot.snapshot.children) {
          final sender = childSnapshot.child('sender').value.toString();
          if (sender == 'seller') {
            statusRead++;
          }
        }
      }

      // ดึงข้อความล่าสุด
      final lastMessageSnapshot = await database
          .child('chats/$sellerId/$chatId/messages')
          .orderByChild('timestamp')
          .limitToLast(1)
          .once();

      if (lastMessageSnapshot.snapshot.exists) {
        final lastMessage = lastMessageSnapshot.snapshot.children.last;
        lastMessageText = lastMessage.child('text').value?.toString() ?? "";
        lastMessageTimestamp = int.tryParse(
                lastMessage.child('timestamp').value?.toString() ?? "0") ??
            0;

        final imageUrl = lastMessage.child('imageUrl').value?.toString() ?? "";

        if (lastMessageText.isEmpty && imageUrl.isNotEmpty) {
          lastMessageText = "📷 Image";
        }
      }

      // อัปเดตค่าใน Model
      for (var chat in messagesList) {
        if (chat.chatRoomId == chatId) {
          chat.statusRead = statusRead;
          chat.lastMessage = lastMessageText;
          chat.lastMessageTime = lastMessageTimestamp;
        }
      }

      messagesList.refresh(); // 🔄 อัปเดต UI
    } catch (error) {
      print('Error fetching lastMessage for chatId $chatId: $error');
    }
  }

  // หยุดฟังทุก chatId เมื่อปิดแอป
  void stopListeningToAllChats() {
    print("🔕 หยุดฟังทุกห้องแชท");

    for (var chatId in _chatListeners.keys) {
      _chatListeners[chatId]!.onDisconnect();
    }

    _chatListeners.clear();
  }

  @override
  void onClose() {
    stopListeningToAllChats();
    super.onClose();
  }

}
