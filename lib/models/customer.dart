class Customer {
  final String id;
  final String username;
  final String email;
  final String imageProfile;
  final String? imageCover;
  final String name;
  final String telephone;

  Customer({
    required this.id,
    required this.username,
    this.name = 'Unknown', // ค่าเริ่มต้น
    this.imageProfile = "",
    this.imageCover = "",
    this.telephone = '', // ค่าเริ่มต้น
    this.email = '', // ค่าเริ่มต้น
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '', // ค่าเริ่มต้นหากไม่มีฟิลด์
      username: json['username'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      imageProfile: json['image_profile'] ?? '',
      imageCover: json['image_cover'] ?? '',
    );
  }
}
