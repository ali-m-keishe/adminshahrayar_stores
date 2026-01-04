// lib/data/models/attribute.dart

class Attribute {
  final int id;
  final String name;
  final String type; // 'single' or 'multiple'
  final bool isRequired;
  final DateTime createdAt;

  Attribute({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    required this.createdAt,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'single',
      isRequired: json['is_required'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'is_required': isRequired,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attribute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

