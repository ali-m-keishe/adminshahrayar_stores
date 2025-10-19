class Customer {
  final String id;
  final String name;
  final double totalSpent;
  final int orderCount;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.totalSpent,
    required this.orderCount,
    required this.phone,
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
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_spent': totalSpent,
      'order_count': orderCount,
      'phone': phone,
    };
  }
}

// Mock Data for the UI
final List<Customer> mockTopCustomers = [
  Customer(
      id: 'c1',
      name: 'Jane Smith',
      totalSpent: 450.50,
      orderCount: 12,
      phone: '123-456-7330'),
  Customer(
      id: 'c2',
      name: 'Mary Johnson',
      totalSpent: 380.00,
      orderCount: 10,
      phone: '123-456-9890'),
  Customer(
      id: 'c3',
      name: 'John Doe',
      totalSpent: 250.75,
      orderCount: 8,
      phone: '123-456-7880'),
  Customer(
      id: 'c4',
      name: 'Peter Jones',
      totalSpent: 180.25,
      orderCount: 6,
      phone: '123-456-7840'),
];
