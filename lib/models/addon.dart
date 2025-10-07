class Addon {
  final int id;
  final String name;
  final double price;
  final DateTime createdAt;

  Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.createdAt,
  });

  // JSON serialization methods
  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
