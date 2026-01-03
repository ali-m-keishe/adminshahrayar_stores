// lib/data/models/menu_item.dart

import 'package:adminshahrayar_stores/data/models/addon.dart';
import 'package:adminshahrayar_stores/data/models/item_size.dart';

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
  final List<Addon>? addons; // ✅ Nullable
  final List<ItemSize>? sizes; // ✅ Nullable

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
    this.addons, // optional
    this.sizes, // optional
  });

  /// 🧩 Deserialize from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
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
      addons: (json['addons'] != null && json['addons'] is List)
          ? (json['addons'] as List)
              .map((e) => Addon.fromJson(e))
              .toList()
          : null,
      sizes: (json['sizes'] != null && json['sizes'] is List)
          ? (json['sizes'] as List)
              .map((e) => ItemSize.fromJson(e))
              .toList()
          : null,
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
      if (addons != null)
        'addons': addons!.map((e) => e.toJson()).toList(),
      if (sizes != null)
        'sizes': sizes!.map((e) => e.toJson()).toList(),
    };
  }
}


