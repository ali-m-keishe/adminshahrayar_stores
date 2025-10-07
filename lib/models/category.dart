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
    return Category(
      id: json['id'] ?? 0,
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
