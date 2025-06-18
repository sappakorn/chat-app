class Product {
  String id;
  String seller_id;
  String seller_name;
  String name;
  String description;
  String image_url;
  String price;
  String count_star;

  Product({
    required this.id,
    required this.seller_id,
    required this.seller_name,
    required this.name,
    required this.description,
    required this.image_url,
    required this.price,
    required this.count_star,
  });

  // ฟังก์ชันในการแปลงข้อมูล JSON เป็น Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      seller_id: json['seller_id'] ?? '',
      seller_name: json['seller']['name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image_url: json['image_url'] ?? '',
      price: json['price']?.toString() ?? '',
      count_star: json['count_star']?.toString() ?? '',
    );
  }
}
