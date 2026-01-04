// lib/data/models/menu_item.dart

import 'package:adminshahrayar_stores/data/models/attribute.dart';

class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int categoryId;
  final DateTime createdAt;
  final bool isActive;
  final int? position;
  final String? arcNo; // ✅ Nullable
  final List<Attribute>? attributes; // ✅ Nullable - replaces addons and sizes

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.createdAt,
    this.isActive = true,
    this.position,
    this.arcNo, // optional
    this.attributes, // optional
  });

  /// 🧩 Deserialize from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Parse attributes from item_attributes relationship
    List<Attribute>? attributes;
    if (json['item_attributes'] != null && json['item_attributes'] is List) {
      final itemAttributes = json['item_attributes'] as List;
      attributes = itemAttributes
          .map((e) {
            // e should have structure: { attribute: { id, name, type, is_required, ... } }
            if (e is Map<String, dynamic> && e['attribute'] != null) {
              return Attribute.fromJson(e['attribute']);
            }
            return null;
          })
          .whereType<Attribute>()
          .toList();
    }

    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      categoryId: json['category_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
      position: json['position'] != null ? (json['position'] is int ? json['position'] : int.tryParse(json['position'].toString())) : null,
      arcNo: json['arc_no'] as String?,
      attributes: attributes?.isEmpty == true ? null : attributes,
    );
  }

  /// 🧩 Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      if (position != null) 'position': position,
      if (arcNo != null && arcNo!.isNotEmpty) 'arc_no': arcNo,
      if (attributes != null)
        'attributes': attributes!.map((e) => e.toJson()).toList(),
    };
  }
}


