import 'package:app/models/customer.dart';
import 'package:app/models/product.dart';
import 'package:app/models/seller.dart';


class CustomerChatModel {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String customerId;
  final String sellerId;
  final String productId;
  final int statusRead;
  final String chatExpired;
  final String chatType;
  final String? serviceType; //เป็น null ได้
  final Seller? seller; //เป็น null ได้
  final Customer? customer; // เป็น null ได้
  final Product? product; //เป็น null ได้

  CustomerChatModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    required this.sellerId,
    required this.productId,
    required this.statusRead,
    required this.chatExpired,
    required this.chatType,
    this.serviceType, //เป็น null ได้
    this.seller, //เป็น null ได้
    this.customer,//เป็น null ได้
    this.product,//เป็น null ได้
  });

  factory CustomerChatModel.fromJson(Map<String, dynamic> json) {
    return CustomerChatModel(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customerId: json['customer_id'],
      sellerId: json['seller_id'],
      productId: json['product_id'],
      statusRead: json['status_read'],
      chatExpired: json['chat_expired'],
      chatType: json['chat_type'],
      serviceType: json['service_type'],
      seller: Seller.fromJson(json['seller']),
      customer: Customer.fromJson(json['customer']),
      product: Product.fromJson(json['product']),
    );
  }
}