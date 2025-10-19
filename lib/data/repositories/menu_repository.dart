import '../models/menu_item.dart';
import '../models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all menu items
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 500));
      return mockMenuItems;
    }
  }

  // Get menu item by name
  Future<MenuItem?> getMenuItemByName(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockMenuItems.firstWhere((item) => item.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get menu items by category ID
  Future<List<MenuItem>> getMenuItemsByCategory(int categoryId) async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockMenuItems
          .where((item) => item.categoryId == categoryId)
          .toList();
    }
  }

  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        Category(
            id: 1, name: 'Main Course', image: '', createdAt: DateTime.now()),
        Category(
            id: 2, name: 'Appetizer', image: '', createdAt: DateTime.now()),
        Category(id: 3, name: 'Dessert', image: '', createdAt: DateTime.now()),
        Category(id: 4, name: 'Sides', image: '', createdAt: DateTime.now()),
      ];
    }
  }

  // Search menu items by name
  Future<List<MenuItem>> searchMenuItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMenuItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get menu items in price range
  Future<List<MenuItem>> getMenuItemsInPriceRange({
    required double minPrice,
    required double maxPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMenuItems
        .where((item) => item.price >= minPrice && item.price <= maxPrice)
        .toList();
  }

  // Get menu items sorted by price
  Future<List<MenuItem>> getMenuItemsSortedByPrice(
      {bool ascending = true}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sortedItems = List<MenuItem>.from(mockMenuItems);
    sortedItems.sort((a, b) =>
        ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    return sortedItems;
  }

  // Add new menu item
  Future<MenuItem> addMenuItem(MenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would make an API call to add the menu item
    return item;
  }

  // Update menu item
  Future<MenuItem> updateMenuItem(MenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the menu item
    return item;
  }

  // Delete menu item
  Future<void> deleteMenuItem(String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would make an API call to delete the menu item
  }

  // Get popular menu items (based on some criteria)
  Future<List<MenuItem>> getPopularMenuItems({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // For demo purposes, return items sorted by price descending
    final popularItems = List<MenuItem>.from(mockMenuItems);
    popularItems.sort((a, b) => b.price.compareTo(a.price));
    return popularItems.take(limit).toList();
  }

  // Get menu statistics
  Future<Map<String, dynamic>> getMenuStatistics() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final categories =
        mockMenuItems.map((item) => item.categoryId).toSet().length;
    final totalItems = mockMenuItems.length;
    final averagePrice =
        mockMenuItems.map((item) => item.price).reduce((a, b) => a + b) /
            totalItems;

    final priceRange = {
      'min': mockMenuItems
          .map((item) => item.price)
          .reduce((a, b) => a < b ? a : b),
      'max': mockMenuItems
          .map((item) => item.price)
          .reduce((a, b) => a > b ? a : b),
    };

    return {
      'totalItems': totalItems,
      'categories': categories,
      'averagePrice': averagePrice,
      'priceRange': priceRange,
    };
  }

  // Get menu items by multiple category IDs
  Future<List<MenuItem>> getMenuItemsByCategories(List<int> categoryIds) async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .inFilter('category_id', categoryIds)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 400));
      return mockMenuItems
          .where((item) => categoryIds.contains(item.categoryId))
          .toList();
    }
  }
}
