class Category {
  final int id;
  final String name;
  final String image;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
