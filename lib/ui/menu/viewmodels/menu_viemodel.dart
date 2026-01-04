// lib/features/menu/menu_viewmodel.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:adminshahrayar_stores/data/models/MenuInventoryState.dart';
import 'package:adminshahrayar_stores/data/models/category.dart';
import 'package:adminshahrayar_stores/data/models/menu_item.dart';
import 'package:adminshahrayar_stores/data/models/attribute.dart';
import 'package:adminshahrayar_stores/data/models/attribute_value.dart';
import 'package:adminshahrayar_stores/data/models/storage_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adminshahrayar_stores/data/repositories/menu_repository.dart';

class MenuViewmodel extends AsyncNotifier<Menuinventorystate> {
  late final MenuRepository _menuRepository;

  @override
  FutureOr<Menuinventorystate> build() async {
    _menuRepository = ref.read(menuRepositoryProvider);
    return _loadMenuData();
  }

  /// 🔹 Load all menu data (categories + items + attributes) - Used for initial load
  Future<Menuinventorystate> _loadMenuData() async {
    try {
      final categories = await _menuRepository.getAllCategories();
      final menuItems = await _menuRepository.getAllMenuItems();
      final attributes = await _menuRepository.getAllAttributes();

      return Menuinventorystate(
        categories: categories,
        menuItems: menuItems,
        attributes: attributes,
        totalMenuItemsCount: menuItems.length,
      );
    } catch (e, stack) {
      print("❌ Error loading menu data: $e");
      print(stack);
      // Return an empty state if something fails
      return Menuinventorystate(
        categories: const [],
        menuItems: const [],
        attributes: const [],
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

  /// 🔹 Refresh categories and attributes (without affecting current pagination)
  Future<void> refreshCategoriesAndAttributes() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      final categories = await _menuRepository.getAllCategories();
      final attributes = await _menuRepository.getAllAttributes();

      state = AsyncValue.data(
        currentState.copyWith(
          categories: categories,
          attributes: attributes,
        ),
      );
    } catch (e, stack) {
      print("❌ Error refreshing categories and attributes: $e");
      print(stack);
    }
  }

  // 🔹 Add Category
  Future<void> addCategory(Category category) async {
    try {
      await _menuRepository.addCategory(category);
      await refreshCategoriesAndAttributes(); // refresh categories only
    } catch (e) {
      print("❌ Error adding category: $e");
    }
  }

  // 🔹 Edit Category
  Future<void> editCategory(Category category) async {
    try {
      await _menuRepository.updateCategory(category);
      await refreshCategoriesAndAttributes(); // refresh categories only
    } catch (e) {
      print("❌ Error editing category: $e");
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _menuRepository.deleteCategory(categoryId);
      await refreshCategoriesAndAttributes(); // refresh categories only
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

  /// 🔹 Add Menu Item (storage URL only)
  Future<void> addMenuItem({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageUrl,
    int? position,
    String? arcNo,
    List<int>? attributeIds, // List of attribute IDs to link
  }) async {
    try {
      await _menuRepository.addMenuItem(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrl: imageUrl,
        position: position,
        arcNo: arcNo,
        attributeIds: attributeIds,
      );
    } catch (e) {
      print("❌ Error adding menu item: $e");
      rethrow;
    }
  }

  /// 🔹 Edit Menu Item (storage URL only)
  Future<void> editMenuItem({
    required int itemId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageUrl,
    String? originalImageUrl,
    List<int>? attributeIds, // List of attribute IDs to link
    bool? isActive,
    int? position,
    String? arcNo,
  }) async {
    try {
      await _menuRepository.updateMenuItem(
        itemId: itemId,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        existingImageUrl: originalImageUrl,
        newImageUrl: imageUrl,
        attributeIds: attributeIds,
        isActive: isActive,
        position: position,
        arcNo: arcNo,
      );
    } catch (e) {
      print("❌ Error editing menu item: $e");
      rethrow;
    }
  }

  // 🔹 Delete item (soft delete - sets is_active = false)
  Future<void> deleteMenuItem(int itemId) async {
    try {
      await _menuRepository.deleteMenuItem(itemId);
      // Note: UI should trigger pagination refresh after this
    } catch (e) {
      print("❌ Error deleting menu item: $e");
      rethrow;
    }
  }

  /// 🔹 Toggle menu item active status
  Future<void> toggleMenuItemActive(int itemId, bool isActive) async {
    try {
      await _menuRepository.toggleMenuItemActive(itemId, isActive);
    } catch (e) {
      print("❌ Error toggling menu item active status: $e");
      rethrow;
    }
  }

  /// 🔹 Load paginated archived menu items with optional category filter
  Future<void> loadPaginatedArchivedMenuItems({
    required int limit,
    required int offset,
    int? categoryId,
  }) async {
    try {
      // Get current state
      final currentState = state.value;
      if (currentState == null) return;

      // Fetch paginated archived items
      final result = await _menuRepository.getPaginatedArchivedMenuItems(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
      );

      final items = result['items'] as List<MenuItem>;
      final totalCount = result['totalCount'] as int;

      // Update state with paginated archived items
      state = AsyncValue.data(
        currentState.copyWith(
          menuItems: items,
          totalMenuItemsCount: totalCount,
        ),
      );
    } catch (e, stack) {
      print("❌ Error loading paginated archived menu items: $e");
      print(stack);
      state = AsyncValue.error(e, stack);
    }
  }

  // ========== ATTRIBUTE METHODS ==========

  /// 🔹 Get all attributes
  Future<List<Attribute>> getAllAttributes() async {
    try {
      return await _menuRepository.getAllAttributes();
    } catch (e) {
      print("❌ Error fetching attributes: $e");
      rethrow;
    }
  }

  /// 🔹 Add Attribute and return the created attribute with ID
  Future<Attribute> addAttribute(Attribute attribute) async {
    try {
      final createdAttribute = await _menuRepository.addAttribute(attribute);
      await refreshCategoriesAndAttributes();
      return createdAttribute;
    } catch (e) {
      print("❌ Error adding attribute: $e");
      rethrow;
    }
  }

  /// 🔹 Update Attribute
  Future<void> updateAttribute(Attribute attribute) async {
    try {
      await _menuRepository.updateAttribute(attribute);
      await refreshCategoriesAndAttributes();
    } catch (e) {
      print("❌ Error updating attribute: $e");
      rethrow;
    }
  }

  /// 🔹 Delete Attribute
  Future<void> deleteAttribute(int attributeId) async {
    try {
      await _menuRepository.deleteAttribute(attributeId);
      await refreshCategoriesAndAttributes();
    } catch (e) {
      print("❌ Error deleting attribute: $e");
      rethrow;
    }
  }

  // ========== ATTRIBUTE VALUE METHODS ==========

  /// 🔹 Get attribute values for an attribute
  Future<List<AttributeValue>> getAttributeValues(int attributeId) async {
    try {
      return await _menuRepository.getAttributeValues(attributeId);
    } catch (e) {
      print("❌ Error fetching attribute values: $e");
      rethrow;
    }
  }

  /// 🔹 Add Attribute Value
  Future<void> addAttributeValue(AttributeValue attributeValue) async {
    try {
      await _menuRepository.addAttributeValue(attributeValue);
    } catch (e) {
      print("❌ Error adding attribute value: $e");
      rethrow;
    }
  }

  /// 🔹 Update Attribute Value
  Future<void> updateAttributeValue(AttributeValue attributeValue) async {
    try {
      await _menuRepository.updateAttributeValue(attributeValue);
    } catch (e) {
      print("❌ Error updating attribute value: $e");
      rethrow;
    }
  }

  /// 🔹 Delete Attribute Value
  Future<void> deleteAttributeValue(int attributeValueId) async {
    try {
      await _menuRepository.deleteAttributeValue(attributeValueId);
    } catch (e) {
      print("❌ Error deleting attribute value: $e");
      rethrow;
    }
  }

  // ========== Storage Category Methods ==========

  /// 🔹 Fetch storage categories (folders from Supabase storage)
  Future<List<String>> fetchStorageCategories() async {
    try {
      return await _menuRepository.fetchStorageCategories();
    } catch (e) {
      print("❌ Error fetching storage categories: $e");
      rethrow;
    }
  }

  /// 🔹 Create a new storage category (folder)
  Future<void> createStorageCategory(String categoryName) async {
    try {
      await _menuRepository.createStorageCategory(categoryName);
    } catch (e) {
      print("❌ Error creating storage category: $e");
      rethrow;
    }
  }

  /// 🔹 Delete a storage category (folder and all its contents)
  Future<void> deleteStorageCategory(String categoryName) async {
    try {
      await _menuRepository.deleteStorageCategory(categoryName);
    } catch (e) {
      print("❌ Error deleting storage category: $e");
      rethrow;
    }
  }

  // ========== Storage Image Methods ==========

  /// 🔹 Fetch images from a specific storage category
  Future<StorageImagesPage> fetchCategoryImages({
    required String category,
    required int limit,
    required int offset,
  }) async {
    try {
      return await _menuRepository.fetchCategoryImages(
        category: category,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print("❌ Error fetching category images: $e");
      rethrow;
    }
  }

  /// 🔹 Upload image to a specific storage category
  Future<String> uploadImageToCategory({
    required Uint8List bytes,
    required String originalFileName,
    required String category,
  }) async {
    try {
      return await _menuRepository.uploadImageToCategory(
        bytes: bytes,
        originalFileName: originalFileName,
        category: category,
      );
    } catch (e) {
      print("❌ Error uploading image to category: $e");
      rethrow;
    }
  }
}

/// ✅ Provider for MenuViewmodel
final menuViewModelProvider =
    AsyncNotifierProvider<MenuViewmodel, Menuinventorystate>(
  () => MenuViewmodel(),
);
