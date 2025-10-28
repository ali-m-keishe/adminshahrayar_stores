// lib/features/menu/menu_viewmodel.dart

import 'dart:async';
import 'package:adminshahrayar/data/models/MenuInventoryState.dart';
import 'package:adminshahrayar/data/models/category.dart';
import 'package:adminshahrayar/data/models/menu_item.dart';
import 'package:adminshahrayar/data/models/addon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adminshahrayar/data/repositories/menu_repository.dart';

class MenuViewmodel extends AsyncNotifier<Menuinventorystate> {
  late final MenuRepository _menuRepository;

  @override
  FutureOr<Menuinventorystate> build() async {
    _menuRepository = ref.read(menuRepositoryProvider);
    return _loadMenuData();
  }

  /// 🔹 Load all menu data (categories + items + addons) - Used for initial load
  Future<Menuinventorystate> _loadMenuData() async {
    try {
      final categories = await _menuRepository.getAllCategories();
      final menuItems = await _menuRepository.getAllMenuItems();
      final addons = await _menuRepository.getAllAddons();

      return Menuinventorystate(
        categories: categories,
        menuItems: menuItems,
        addons: addons,
        totalMenuItemsCount: menuItems.length,
      );
    } catch (e, stack) {
      print("❌ Error loading menu data: $e");
      print(stack);
      // Return an empty state if something fails
      return Menuinventorystate(
        categories: const [],
        menuItems: const [],
        addons: const [],
        totalMenuItemsCount: 0,
      );
    }
  }

  /// 🔹 Load paginated menu data with optional category filter
  Future<void> loadPaginatedMenuItems({
    required int limit,
    required int offset,
    int? categoryId,
  }) async {
    try {
      // Get current state
      final currentState = state.value;
      if (currentState == null) return;

      // Fetch paginated items
      final result = await _menuRepository.getPaginatedMenuItems(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
      );

      final items = result['items'] as List<MenuItem>;
      final totalCount = result['totalCount'] as int;

      // Update state with paginated items
      state = AsyncValue.data(
        currentState.copyWith(
          menuItems: items,
          totalMenuItemsCount: totalCount,
        ),
      );
    } catch (e, stack) {
      print("❌ Error loading paginated menu items: $e");
      print(stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// 🔹 Refresh categories and addons (without affecting current pagination)
  Future<void> refreshCategoriesAndAddons() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      final categories = await _menuRepository.getAllCategories();
      final addons = await _menuRepository.getAllAddons();

      state = AsyncValue.data(
        currentState.copyWith(
          categories: categories,
          addons: addons,
        ),
      );
    } catch (e, stack) {
      print("❌ Error refreshing categories and addons: $e");
      print(stack);
    }
  }

  // 🔹 Add Category
  Future<void> addCategory(Category category) async {
    try {
      await _menuRepository.addCategory(category);
      await refreshCategoriesAndAddons(); // refresh categories only
    } catch (e) {
      print("❌ Error adding category: $e");
    }
  }

  // 🔹 Edit Category
  Future<void> editCategory(Category category) async {
    try {
      await _menuRepository.updateCategory(category);
      await refreshCategoriesAndAddons(); // refresh categories only
    } catch (e) {
      print("❌ Error editing category: $e");
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _menuRepository.deleteCategory(categoryId);
      await refreshCategoriesAndAddons(); // refresh categories only
    } catch (e, st) {
      print("❌ Error deleting category: $e");
      state = AsyncValue.error(e, st);
    }
  }

  /// 🔄 Refresh the entire menu (use sparingly - for full reload)
  Future<void> refreshMenu() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await _loadMenuData());
  }

  Future<void> addMenuItem(MenuItem item) async {
    try {
      await _menuRepository.addMenuItem(item);
      // Note: UI should trigger pagination refresh after this
    } catch (e) {
      print("❌ Error adding menu item: $e");
      rethrow;
    }
  }

  // 🔹 Edit item
  Future<void> editMenuItem(MenuItem item) async {
    try {
      await _menuRepository.updateMenuItem(item);
      // Note: UI should trigger pagination refresh after this
    } catch (e) {
      print("❌ Error editing menu item: $e");
      rethrow;
    }
  }

  // 🔹 Delete item
  Future<void> deleteMenuItem(int itemId) async {
    try {
      await _menuRepository.deleteMenuItem(itemId);
      // Note: UI should trigger pagination refresh after this
    } catch (e) {
      print("❌ Error deleting menu item: $e");
      rethrow;
    }
  }

  // 🔹 Add Addon
  Future<void> addAddon(Addon addon) async {
    try {
      await _menuRepository.addAddon(addon);
      await refreshCategoriesAndAddons(); // refresh addons only
    } catch (e) {
      print("❌ Error adding addon: $e");
    }
  }

  // 🔹 Delete Addon
  Future<void> deleteAddon(int addonId) async {
    try {
      await _menuRepository.deleteAddon(addonId);
      await refreshCategoriesAndAddons(); // refresh addons only
    } catch (e) {
      print("❌ Error deleting addon: $e");
    }
  }
}

/// ✅ Provider for MenuViewmodel
final menuViewModelProvider =
    AsyncNotifierProvider<MenuViewmodel, Menuinventorystate>(
  () => MenuViewmodel(),
);
