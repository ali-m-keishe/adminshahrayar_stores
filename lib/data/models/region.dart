class Region {
  final int id;
  final String name;
  final int deliveryFee;
  final DateTime createdAt;

  Region({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.createdAt,
  });

  // JSON serialization methods
  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      deliveryFee: json['delivery_fee'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'delivery_fee': deliveryFee,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields for editing
  Region copyWith({
    String? name,
    int? deliveryFee,
  }) {
    return Region(
      id: id,
      name: name ?? this.name,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt,
    );
  }
}

