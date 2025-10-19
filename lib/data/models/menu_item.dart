class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int categoryId;
  final DateTime createdAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.createdAt,
  });

  // JSON serialization methods
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      categoryId: json['category_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

final List<MenuItem> mockMenuItems = [
  MenuItem(
    id: 1,
    name: 'Classic Burger',
    description: 'Juicy beef patty with fresh vegetables',
    price: 12.99,
    image: 'https://placehold.co/400x300/f87171/ffffff?text=Burger',
    categoryId: 1,
    createdAt: DateTime.now(),
  ),
  MenuItem(
    id: 2,
    name: 'Margherita Pizza',
    description: 'Traditional pizza with tomato and mozzarella',
    price: 15.50,
    image: 'https://placehold.co/400x300/fb923c/ffffff?text=Pizza',
    categoryId: 1,
    createdAt: DateTime.now(),
  ),
  MenuItem(
    id: 3,
    name: 'Caesar Salad',
    description: 'Fresh romaine lettuce with caesar dressing',
    price: 9.75,
    image: 'https://placehold.co/400x300/a3e635/ffffff?text=Salad',
    categoryId: 2,
    createdAt: DateTime.now(),
  ),
  MenuItem(
    id: 4,
    name: 'Chocolate Lava Cake',
    description: 'Warm chocolate cake with molten center',
    price: 7.50,
    image: 'https://placehold.co/400x300/7c3aed/ffffff?text=Cake',
    categoryId: 3,
    createdAt: DateTime.now(),
  ),
  MenuItem(
    id: 5,
    name: 'Spaghetti Carbonara',
    description: 'Classic Italian pasta with cream sauce',
    price: 14.00,
    image: 'https://placehold.co/400x300/38bdf8/ffffff?text=Pasta',
    categoryId: 1,
    createdAt: DateTime.now(),
  ),
  MenuItem(
    id: 6,
    name: 'French Fries',
    description: 'Crispy golden french fries',
    price: 4.50,
    image: 'https://placehold.co/400x300/facc15/ffffff?text=Fries',
    categoryId: 4,
    createdAt: DateTime.now(),
  ),
];
