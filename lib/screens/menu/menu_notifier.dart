import 'package:adminshahrayar/models/menu_item.dart';
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
class MenuNotifier extends StateNotifier<MenuState> {
  MenuNotifier() : super(MenuState()) {
    _fetchMenuItems();
  }

  void _fetchMenuItems() {
    state = state.copyWith(menuItems: mockMenuItems);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void addCategory(String newCategory) {
    final trimmedCategory = newCategory.trim();
    if (trimmedCategory.isEmpty ||
        state.categories
            .any((c) => c.toLowerCase() == trimmedCategory.toLowerCase())) {
      return;
    }
    final updatedCategories = [...state.categories, trimmedCategory];
    state = state.copyWith(categories: updatedCategories);
  }

  void updateCategory(String oldName, String newName) {
    final trimmedNewName = newName.trim();
    if (trimmedNewName.isEmpty ||
        state.categories
            .any((c) => c.toLowerCase() == trimmedNewName.toLowerCase())) {
      return;
    }

    final updatedCategories =
        state.categories.map((c) => c == oldName ? trimmedNewName : c).toList();
    final updatedMenuItems = state.menuItems.map((item) {
      if (item.category == oldName) {
        return MenuItem(
          name: item.name,
          price: item.price,
          category: trimmedNewName,
          imageUrl: item.imageUrl,
        );
      }
      return item;
    }).toList();

    final newSelectedCategory = state.selectedCategory == oldName
        ? trimmedNewName
        : state.selectedCategory;

    state = state.copyWith(
      categories: updatedCategories,
      menuItems: updatedMenuItems,
      selectedCategory: newSelectedCategory,
    );
  }

  void addMenuItem(MenuItem newItem) {
    state = state.copyWith(menuItems: [...state.menuItems, newItem]);
  }

  void updateMenuItem(MenuItem updatedItem) {
    state = state.copyWith(
      menuItems: state.menuItems.map((item) {
        return item.name == updatedItem.name ? updatedItem : item;
      }).toList(),
    );
  }

  void deleteMenuItem(String itemName) {
    state = state.copyWith(
      menuItems:
          state.menuItems.where((item) => item.name != itemName).toList(),
    );
  }
}

// Providers remain the same.
final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier();
});

final filteredMenuItemsProvider = Provider<List<MenuItem>>((ref) {
  final menuState = ref.watch(menuProvider);
  if (menuState.selectedCategory == 'All') {
    return menuState.menuItems;
  }
  return menuState.menuItems
      .where((item) => item.category == menuState.selectedCategory)
      .toList();
});
