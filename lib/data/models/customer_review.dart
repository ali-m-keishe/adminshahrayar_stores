class Customer {
  final String id;
  final String name;
  final double totalSpent;
  final int orderCount;
  final String? phone;
  final String? email;

  Customer({
    required this.id,
    required this.name,
    required this.totalSpent,
    required this.orderCount,
    this.phone,
    this.email,
  });

  // Helper getter to create an avatar letter from the name
  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';

  // JSON serialization methods
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      orderCount: json['order_count'] ?? 0,
      phone: json['phone'],
      email: json['email'],
    );
  }

  factory Customer.fromAuthUser(Map<String, dynamic> json) {
  return Customer(
    id: json['id'].toString(),
    name: json['email'] ?? 'Unknown User', // Auth users have no name
    email: json['email'],
    phone: json['phone'],
    totalSpent: 0.0, // Not available yet
    orderCount: 0,   // Not available yet
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_spent': totalSpent,
      'order_count': orderCount,
      'phone': phone,
      'email': email,
    };
  }
}

