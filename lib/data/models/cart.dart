class Cart {
  final int cartId;
  final String status;
  final String userId;
  final double totalPrice;
  final DateTime createdAt;
  final String? username;
  final String? phone;
  final String? email;

  Cart({
    required this.cartId,
    required this.status,
    required this.userId,
    required this.totalPrice,
    required this.createdAt,
    this.username,
    this.phone,
    this.email,
  });

  // JSON serialization methods
  factory Cart.fromJson(Map<String, dynamic> json) {
    final username = json['username'] ?? json['user_name'];
    final phone = json['phone'];
    final email = json['email'];
    print('📥 Cart.fromJson - username: $username, phone: $phone, email: $email');
    print('📥 Cart.fromJson - json keys: ${json.keys.toList()}');
    return Cart(
      cartId: json['cart_id'] ?? 0,
      status: json['status'] ?? '',
      userId: json['user_id'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      username: username,
      phone: phone,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'status': status,
      'user_id': userId,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'phone': phone,
      'email': email,
    };
  }
}

class CartItem {
  final int id;
  final int cartId;
  final int quantity;
  final String note;
  final int itemId;
  final int? sizeId;
  final List<dynamic> cartItemAddons;
  final double price;
  final bool hasOffer;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.cartId,
    required this.quantity,
    required this.note,
    required this.itemId,
    this.sizeId,
    required this.cartItemAddons,
    required this.price,
    required this.hasOffer,
    required this.createdAt,
  });

  // JSON serialization methods
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      cartId: json['cart_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      note: json['note'] ?? '',
      itemId: json['item_id'] ?? 0,
      sizeId: json['size_id'],
      cartItemAddons: json['cart_item_addons'] ?? [],
      price: (json['price'] ?? 0).toDouble(),
      hasOffer: json['has_offer'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'quantity': quantity,
      'note': note,
      'item_id': itemId,
      'size_id': sizeId,
      'cart_item_addons': cartItemAddons,
      'price': price,
      'has_offer': hasOffer,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
