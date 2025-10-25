// lib/data/repositories/menu_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

final supabase = Supabase.instance.client;

class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔹 Fetch all categories
  Future<List<Category>> getAllCategories() async {
    try {
      print('Fetching all categories from Supabase...');
      final response = await _supabase
          .from('categories')
          .select('*')
          .order('created_at', ascending: false);

      print('✅ Categories fetched: ${response?.length ?? 0}');

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('❌ Error fetching categories: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Fetch all menu items (with category + optional addons & sizes)
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final response = await _supabase.from('items').select('''
      *,
      category:category_id (id, name, image, created_at),
      item_addons (
        addon:addon_id (*)
      ),
      item_sizes (*)
    ''').order('created_at', ascending: false);

      final items = (response as List).map((json) {
        final map = Map<String, dynamic>.from(json);

        // Flatten item_addons → addons
        if (map['item_addons'] != null) {
          map['addons'] = (map['item_addons'] as List)
              .map((e) => e['addon'])
              .where((a) => a != null)
              .toList();
        }

        // Flatten item_sizes → sizes (only S, M, L)
        if (map['item_sizes'] != null) {
          map['sizes'] = (map['item_sizes'] as List)
              .where((s) =>
                  s['size_name'] == 'S' ||
                  s['size_name'] == 'M' ||
                  s['size_name'] == 'L')
              .toList();
        }

        if (map['category'] != null) {
          map['category_name'] = map['category']['name'];
        }

        return MenuItem.fromJson(map);
      }).toList();

      return items;
    } catch (e, stack) {
      print('❌ Error fetching menu items: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Add a new menu item (with optional addons and sizes)
  Future<void> addMenuItem(MenuItem item) async {
    try {
      print('🟢 Adding new menu item: ${item.name}');
      await _supabase.from('items').insert(item.toJson());
      print('✅ Menu item added successfully!');
    } catch (e, stack) {
      print('❌ Error adding menu item: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Delete a menu item by ID
  Future<void> deleteMenuItem(int id) async {
    try {
      print('🗑️ Deleting menu item with ID: $id');
      await _supabase.from('items').delete().eq('id', id);
      print('✅ Menu item deleted successfully!');
    } catch (e, stack) {
      print('❌ Error deleting menu item: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Update a menu item by ID
  Future<void> updateMenuItem(MenuItem item) async {
    try {
      print('✏️ Updating menu item with ID: ${item.id}');
      await _supabase.from('items').update(item.toJson()).eq('id', item.id);
      print('✅ Menu item updated successfully!');
    } catch (e, stack) {
      print('❌ Error updating menu item: $e');
      print(stack);
      rethrow;
    }
  }
}

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});
