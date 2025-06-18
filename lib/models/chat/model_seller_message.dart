class ModelSellerMessage {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String chatRoomId;
  final String customerId;
  final String sellerId;
  int statusRead; // ✅ ต้องไม่เป็น final เพราะต้องอัปเดตได้
  final String chatType;
  final bool statusPin;
  final String chatExpired;

  final String sellerName;
  final String sellerLogo;

  final String customerName;
  final String customerImage;

  final String productId;
  final String productName;
  final String productImage;
  String lastMessage; // ✅ ต้องไม่เป็น final เพราะต้องอัปเดตได้
  int lastMessageTime;

  ModelSellerMessage({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.chatRoomId,
    required this.customerId,
    required this.sellerId,
    required this.statusRead,
    required this.chatType,
    required this.statusPin,
    required this.chatExpired,
    required this.sellerName,
    required this.sellerLogo,
    required this.customerName,
    required this.customerImage,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  // ✅ แปลง JSON เป็น Object
  factory ModelSellerMessage.fromJson(Map<String, dynamic> json) {
    return ModelSellerMessage(
      id: json["id"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      chatRoomId: json["id"] ?? "",
      customerId: json["customer_id"] ?? "",
      sellerId: json["seller_id"] ?? "",
      statusRead: 0, // ✅ ค่าเริ่มต้น
      chatType: json["chat_type"] ?? "",
      statusPin: json["status_pin"] ?? false,
      chatExpired: json["chat_expired"] ?? "",

      sellerName: json["seller"]?["name"] ?? "ไม่ระบุชื่อร้าน",
      sellerLogo: json["seller"]?["logo_mobile_image"] ??
          "https://placehold.co/100x100",

      customerName: json["customer"]?["name"] ?? "ไม่ระบุชื่อลูกค้า",
      customerImage:
          json["customer"]?["image_profile"] ?? "https://placehold.co/100x100",

      productId: json["product"]?["id"] ?? "",
      productName: json["product"]?["name"] ?? "ไม่มีชื่อสินค้า",
      productImage:
          json["product"]?["image_url"] ?? "https://placehold.co/200x200",

      lastMessage: json["lastMessage"] ?? "",
      lastMessageTime: json["lastMessageTime"] ?? 0,
    );
  }

  // ✅ แปลง List ของ JSON เป็น List ของ Model
  static List<ModelSellerMessage> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ModelSellerMessage.fromJson(json)).toList();
  }
}