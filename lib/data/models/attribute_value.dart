// lib/data/models/attribute_value.dart

class AttributeValue {
  final int id;
  final int attributeId;
  final String name;
  final double price;
  final DateTime createdAt;

  AttributeValue({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.price,
    required this.createdAt,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      attributeId: json['attribute_id'] is int 
          ? json['attribute_id'] 
          : int.tryParse(json['attribute_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute_id': attributeId,
      'name': name,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttributeValue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

