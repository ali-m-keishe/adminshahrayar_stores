import 'package:adminshahrayar/data/models/menu_item.dart';
import 'package:adminshahrayar/data/repositories/menu_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The MenuState class, updated to allow categories to be changed.
class MenuState {
  final List<MenuItem> menuItems;
  final String selectedCategory;
  final List<String> categories;

  MenuState({
    this.menuItems = const [],
    this.selectedCategory = 'All',
    this.categories = const [
      'All',
      'Main Course',
      'Appetizer',
      'Dessert',
      'Sides'
    ],
  });

  MenuState copyWith({
    List<MenuItem>? menuItems,
    String? selectedCategory,
    List<String>? categories,
  }) {
    return MenuState(
      menuItems: menuItems ?? this.menuItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
    );
  }
}

// The MenuNotifier, now with both addCategory and updateCategory methods.
class MenuNotifier extends AsyncNotifier<MenuState> {
  final MenuRepository _menuRepository = MenuRepository();

  @override
  Future<MenuState> build() async {
    try {
      final menuItems = await _menuRepository.getAllMenuItems();
      final categories = await _menuRepository.getCategories();
      return MenuState(
        menuItems: menuItems,
        categories: ['All', ...categories.map((c) => c.name)],
      );
    } catch (e) {
      return MenuState(menuItems: mockMenuItems);
    }
  }

  Future<void> refreshMenuItems() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await build());
  }

  void selectCategory(String category) {
    final current = state.valueOrNull ?? MenuState();
    state = AsyncData(current.copyWith(selectedCategory: category));
  }

  void addCategory(String newCategory) {
    final current = state.valueOrNull ?? MenuState();
    final trimmedCategory = newCategory.trim();
    if (trimmedCategory.isEmpty ||
        current.categories
            .any((c) => c.toLowerCase() == trimmedCategory.toLowerCase())) {
      return;
    }
    final updatedCategories = [...current.categories, trimmedCategory];
    state = AsyncData(current.copyWith(categories: updatedCategories));
  }

  void updateCategory(String oldName, String newName) {
    final current = state.valueOrNull ?? MenuState();
    final trimmedNewName = newName.trim();
    if (trimmedNewName.isEmpty ||
        current.categories
            .any((c) => c.toLowerCase() == trimmedNewName.toLowerCase())) {
      return;
    }

    final updatedCategories = current.categories
        .map((c) => c == oldName ? trimmedNewName : c)
        .toList();
    final updatedMenuItems = current.menuItems.map((item) {
      if (item.categoryId.toString() == oldName) {
        return MenuItem(
          id: item.id,
          name: item.name,
          description: item.description,
          price: item.price,
          image: item.image,
          categoryId: item.categoryId,
          createdAt: item.createdAt,
        );
      }
      return item;
    }).toList();

    final newSelectedCategory = current.selectedCategory == oldName
        ? trimmedNewName
        : current.selectedCategory;

    state = AsyncData(current.copyWith(
      categories: updatedCategories,
      menuItems: updatedMenuItems,
      selectedCategory: newSelectedCategory,
    ));
  }

  Future<void> addMenuItem(MenuItem newItem) async {
    try {
      await _menuRepository.addMenuItem(newItem);
      await refreshMenuItems(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateMenuItem(MenuItem updatedItem) async {
    try {
      await _menuRepository.updateMenuItem(updatedItem);
      await refreshMenuItems(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteMenuItem(String itemName) async {
    try {
      await _menuRepository.deleteMenuItem(itemName);
      await refreshMenuItems(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }
}

// Providers remain the same.
final menuProvider = AsyncNotifierProvider<MenuNotifier, MenuState>(() {
  return MenuNotifier();
});

final filteredMenuItemsProvider = Provider<List<MenuItem>>((ref) {
  final menuState = ref.watch(menuProvider);
  return menuState.when(
    loading: () => const <MenuItem>[],
    error: (_, __) => const <MenuItem>[],
    data: (data) {
      if (data.selectedCategory == 'All') {
        return data.menuItems;
      }
      return data.menuItems
          .where((item) => item.categoryId.toString() == data.selectedCategory)
          .toList();
    },
  );
});
