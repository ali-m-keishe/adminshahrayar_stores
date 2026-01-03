class Category {
  final int id;
  final String name;
  final String image;
  final DateTime createdAt;
  final int? position;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    this.position,
  });

  // JSON serialization methods
  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle bigint from database - it can come as int or String
    int parseId(dynamic id) {
      if (id == null) return 0;
      if (id is int) return id;
      if (id is String) return int.tryParse(id) ?? 0;
      return 0;
    }

    return Category(
      id: parseId(json['id']),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      position: json['position'] != null ? (json['position'] is int ? json['position'] : int.tryParse(json['position'].toString())) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      if (position != null) 'position': position,
    };
  }
}
