// The OrderItem class MUST be defined here like this.
// This will fix the errors related to 'itemName', 'quantity', and 'modifiers'.
class OrderItem {
  final String itemName;
  final int quantity;
  final List<String> modifiers;

  OrderItem({
    required this.itemName,
    required this.quantity,
    this.modifiers = const [],
  });

  // JSON serialization methods
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      modifiers: List<String>.from(json['modifiers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'quantity': quantity,
      'modifiers': modifiers,
    };
  }
}

// Note: legacy enums kept previously have been removed. Status is now a
// Supabase string: 'pending' | 'on the way' | 'done'.

class Order {
  final int id;
  final int cartId;
  final String status;
  final String paymentToken;
  final int? addressId;
  final DateTime createdAt;
  final String? addressFormatted;

  Order({
    required this.id,
    required this.cartId,
    required this.status,
    required this.paymentToken,
    this.addressId,
    required this.createdAt,
    this.addressFormatted,
  });

  // JSON serialization methods
  factory Order.fromJson(Map<String, dynamic> json) {
    String? formattedAddress;
    if (json['address'] != null && json['address'] is Map) {
      final map = json['address'] as Map;
      formattedAddress = (map['formatted_address'] ?? map['custom_label']) as String?;
    } else if (json['address_formatted'] != null) {
      formattedAddress = json['address_formatted'] as String?;
    }

    return Order(
      id: json['id'] ?? 0,
      cartId: json['cart_id'] ?? 0,
      status: json['status'] ?? '',
      paymentToken: json['payment_token'] ?? '',
      addressId: json['address_id'] as int?,
      createdAt: DateTime.parse(json['created_at']),
      addressFormatted: formattedAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'status': status,
      'payment_token': paymentToken,
      if (addressId != null) 'address_id': addressId,
      'created_at': createdAt.toIso8601String(),
      if (addressFormatted != null) 'address_formatted': addressFormatted,
    };
  }
}

// Mock data using the correct structure
final List<Order> mockOrders = [
  Order(
    id: 1,
    cartId: 1,
    status: 'done',
    paymentToken: 'tok_123456789',
    addressId: 1,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    addressFormatted: '123 Main St',
  ),
  Order(
    id: 2,
    cartId: 2,
    status: 'pending',
    paymentToken: 'tok_987654321',
    addressId: 2,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Order(
    id: 3,
    cartId: 3,
    status: 'done',
    paymentToken: 'tok_555666777',
    addressId: 3,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Order(
    id: 4,
    cartId: 4,
    status: 'done',
    paymentToken: 'tok_111222333',
    addressId: 4,
    createdAt: DateTime.now().subtract(const Duration(days: 40)),
  ),
  Order(
    id: 5,
    cartId: 5,
    status: 'on the way',
    paymentToken: 'tok_444555666',
    addressId: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 400)),
  ),
];
