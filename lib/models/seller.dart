class Seller {
  final String id;
  final String name;
  final String logoUrl;
  final String address;
  final String province;
  final String district;
  final String telephone;

  Seller({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.address,
    required this.province,
    required this.district,
    required this.telephone,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_website_image'],
      address: json['address'],
      province: json['province'],
      district: json['district'],
      telephone: json['telephone'],
    );
  }
}