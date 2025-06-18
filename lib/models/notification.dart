class ModelNotification {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String title;
  final String message;
  final String icon;
  final String image;
  final String customerId;
  final String type;
  final int statusRead;
  final String actionUrl;

  ModelNotification({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.message,
    required this.icon,
    required this.image,
    required this.customerId,
    required this.type,
    required this.statusRead,
    required this.actionUrl,
  });

  factory ModelNotification.fromJson(Map<String, dynamic> json) {
    return ModelNotification(
      id: json["id"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      title: json["title"] ?? "ไม่มีหัวข้อ",
      message: json["message"] ?? "ไม่มีข้อความ",
      icon: json["icon"] ?? "https://placehold.co/50x50",
      image: json["image"] ?? "https://placehold.co/300x300",
      customerId: json["customer_id"] ?? "",
      type: json["type"] ?? "",
      statusRead: json["status_read"] ?? 0,
      actionUrl: json["action_url"] ?? "",
    );
  }

  static List<ModelNotification> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ModelNotification.fromJson(json)).toList();
  }
}
