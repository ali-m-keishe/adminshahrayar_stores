class MenuItem {
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });
}

final List<MenuItem> mockMenuItems = [
  MenuItem(
    name: 'Classic Burger',
    price: 12.99,
    category: 'Main Course',
    imageUrl: 'https://placehold.co/400x300/f87171/ffffff?text=Burger',
  ),
  MenuItem(
    name: 'Margherita Pizza',
    price: 15.50,
    category: 'Main Course',
    imageUrl: 'https://placehold.co/400x300/fb923c/ffffff?text=Pizza',
  ),
  MenuItem(
    name: 'Caesar Salad',
    price: 9.75,
    category: 'Appetizer',
    imageUrl: 'https://placehold.co/400x300/a3e635/ffffff?text=Salad',
  ),
  MenuItem(
    name: 'Chocolate Lava Cake',
    price: 7.50,
    category: 'Dessert',
    imageUrl: 'https://placehold.co/400x300/7c3aed/ffffff?text=Cake',
  ),
  MenuItem(
    name: 'Spaghetti Carbonara',
    price: 14.00,
    category: 'Main Course',
    imageUrl: 'https://placehold.co/400x300/38bdf8/ffffff?text=Pasta',
  ),
  MenuItem(
    name: 'French Fries',
    price: 4.50,
    category: 'Sides',
    imageUrl: 'https://placehold.co/400x300/facc15/ffffff?text=Fries',
  ),
];
