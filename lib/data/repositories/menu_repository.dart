// lib/data/repositories/menu_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/addon.dart';

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

      print('✅ Categories fetched: ${response.length}');

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('❌ Error fetching categories: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Fetch all addons
  Future<List<Addon>> getAllAddons() async {
    try {
      print('Fetching all addons from Supabase...');
      final response = await _supabase
          .from('addons')
          .select('*')
          .order('created_at', ascending: false);

      print('✅ Addons fetched: ${response.length}');

      return (response as List)
          .map((json) => Addon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('❌ Error fetching addons: $e');
      print(stack);
      return [];
    }
  }

  /// 🔹 Add a new addon
  Future<void> addAddon(Addon addon) async {
    try {
      print('🟢 Adding new addon: ${addon.name}');

      final data = {
        'name': addon.name,
        'price': addon.price,
        'created_at': addon.createdAt.toIso8601String(),
        // don't include 'id' here - it's auto-generated
      };

      await _supabase.from('addons').insert(data);
      print('✅ Addon added successfully!');
    } catch (e, stack) {
      print('❌ Error adding addon: $e');
      print(stack);
      rethrow;
    }
  }

  /// 🔹 Delete addon
  Future<void> deleteAddon(int id) async {
    try {
      print('🗑️ Deleting addon ID: $id');
      await _supabase.from('addons').delete().eq('id', id);
      print('✅ Addon deleted successfully!');
    } catch (e, stack) {
      print('❌ Error deleting addon: $e');
      print(stack);
      rethrow;
    }
  }

  // 🔹 Add a new category
  Future<void> addCategory(Category category) async {
    try {
      print('🟢 Adding new category: ${category.name}');

      final data = {
        'name': category.name,
        'image': category.image,
        'created_at': category.createdAt.toIso8601String(),
        // don't include 'id' here
      };

      await _supabase.from('categories').insert(data);
      print('✅ Category added successfully!');
    } catch (e, stack) {
      print('❌ Error adding category: $e');
      print(stack);
      rethrow;
    }
  }

// 🔹 Update existing category
  Future<void> updateCategory(Category category) async {
    try {
      print('✏️ Updating category ID: ${category.id}');
      await _supabase
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id);
      print('✅ Category updated successfully!');
    } catch (e, stack) {
      print('❌ Error updating category: $e');
      print(stack);
      rethrow;
    }
  }

// 🔹 Delete category (optional)
  Future<void> deleteCategory(int id) async {
    try {
      print('🗑️ Deleting category ID: $id');
      await _supabase.from('categories').delete().eq('id', id);
      print('✅ Category deleted successfully!');
    } catch (e, stack) {
      print('❌ Error deleting category: $e');
      print(stack);
      rethrow;
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

        // Flatten item_sizes → sizes (all sizes)
        if (map['item_sizes'] != null) {
          map['sizes'] = (map['item_sizes'] as List).toList();
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

  /// 🔹 Fetch paginated menu items with optional category filter
  Future<Map<String, dynamic>> getPaginatedMenuItems({
    required int limit,
    required int offset,
    int? categoryId,
  }) async {
    try {
      print('🔍 Fetching paginated items: limit=$limit, offset=$offset, categoryId=$categoryId');

      // Build queries with proper filter chain
      dynamic countQuery;
      dynamic itemQuery;
      
      if (categoryId != null) {
        // With category filter
        countQuery = _supabase
            .from('items')
            .select('id')
            .eq('category_id', categoryId);
        
        itemQuery = _supabase
            .from('items')
            .select('''
              *,
              category:category_id (id, name, image, created_at),
              item_addons (
                addon:addon_id (*)
              ),
              item_sizes (*)
            ''')
            .eq('category_id', categoryId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      } else {
        // Without category filter
        countQuery = _supabase.from('items').select('id');
        
        itemQuery = _supabase
            .from('items')
            .select('''
              *,
              category:category_id (id, name, image, created_at),
              item_addons (
                addon:addon_id (*)
              ),
              item_sizes (*)
            ''')
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
      }
      
      // Get total count
      final countResult = await countQuery;
      final totalCount = (countResult as List).length;

      // Execute item query
      final itemsResponse = await itemQuery;

      // Parse items
      final items = (itemsResponse as List).map((json) {
        final map = Map<String, dynamic>.from(json);

        // Flatten item_addons → addons
        if (map['item_addons'] != null) {
          map['addons'] = (map['item_addons'] as List)
              .map((e) => e['addon'])
              .where((a) => a != null)
              .toList();
        }

        // Flatten item_sizes → sizes (all sizes)
        if (map['item_sizes'] != null) {
          map['sizes'] = (map['item_sizes'] as List).toList();
        }

        if (map['category'] != null) {
          map['category_name'] = map['category']['name'];
        }

        return MenuItem.fromJson(map);
      }).toList();

      print('✅ Fetched ${items.length} items (total: $totalCount)');

      return {
        'items': items,
        'totalCount': totalCount,
      };
    } catch (e, stack) {
      print('❌ Error fetching paginated menu items: $e');
      print(stack);
      return {
        'items': <MenuItem>[],
        'totalCount': 0,
      };
    }
  }

  /// 🔹 Add a new menu item (with optional addons and sizes)
  Future<void> addMenuItem(MenuItem item) async {
    try {
      print('🟢 Adding new menu item: ${item.name}');

      // 1️⃣ Insert the main menu item
      final response = await _supabase.from('items').insert({
        'name': item.name,
        'price': item.price,
        'description': item.description,
        'category_id': item.categoryId,
        'image': item.image,
        'created_at': item.createdAt.toIso8601String(),
      }).select();

      final newItem = (response as List).first as Map<String, dynamic>;
      final newItemId = newItem['id'] as int;

      // 2️⃣ Link addons (if any selected) - CORRECTLY inserts into junction table
      if (item.addons != null && item.addons!.isNotEmpty) {
        final addonData = item.addons!
            .map((a) => {
                  'item_id': newItemId,
                  'addon_id': a.id,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();

        await _supabase.from('item_addons').insert(addonData);
        print('✅ Linked ${item.addons!.length} addons to item $newItemId');
      }

      // 3️⃣ Add sizes (if any)
      if (item.sizes != null && item.sizes!.isNotEmpty) {
        final sizeData = item.sizes!
            .map((s) => {
                  'item_id': newItemId,
                  'size_name': s.sizeName,
                  'additional_price': s.additionalPrice,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();

        await _supabase.from('item_sizes').insert(sizeData);
        print('✅ Added ${item.sizes!.length} sizes to item $newItemId');
      }

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

  /// 🔹 Update a menu item by ID (with addons and sizes)
  Future<void> updateMenuItem(MenuItem item) async {
    try {
      print('✏️ Updating menu item with ID: ${item.id}');
      
      // 1️⃣ Update the main item fields
      await _supabase.from('items').update({
        'name': item.name,
        'price': item.price,
        'description': item.description.isEmpty ? null : item.description,
        'category_id': item.categoryId,
        'image': item.image.isEmpty ? null : item.image,
      }).eq('id', item.id);

      // 2️⃣ Update addons: Delete old ones and insert new ones
      // Delete existing addon relationships
      await _supabase.from('item_addons').delete().eq('item_id', item.id);
      
      // Insert new addon relationships if any
      if (item.addons != null && item.addons!.isNotEmpty) {
        final addonData = item.addons!
            .map((a) => {
                  'item_id': item.id,
                  'addon_id': a.id,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();
        await _supabase.from('item_addons').insert(addonData);
        print('✅ Updated ${item.addons!.length} addons for item ${item.id}');
      }

      // 3️⃣ Update sizes: Delete old ones and insert new ones
      // Delete existing sizes
      await _supabase.from('item_sizes').delete().eq('item_id', item.id);
      
      // Insert new sizes if any
      if (item.sizes != null && item.sizes!.isNotEmpty) {
        final sizeData = item.sizes!
            .map((s) => {
                  'item_id': item.id,
                  'size_name': s.sizeName,
                  'additional_price': s.additionalPrice,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();
        await _supabase.from('item_sizes').insert(sizeData);
        print('✅ Updated ${item.sizes!.length} sizes for item ${item.id}');
      }

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
