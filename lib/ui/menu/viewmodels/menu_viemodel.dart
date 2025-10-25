// lib/features/menu/menu_viewmodel.dart

import 'dart:async';
import 'package:adminshahrayar/data/models/MenuInventoryState.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adminshahrayar/data/repositories/menu_repository.dart';

class MenuViewmodel extends AsyncNotifier<Menuinventorystate> {
  late final MenuRepository _menuRepository;

  @override
  FutureOr<Menuinventorystate> build() async {
    _menuRepository = ref.read(menuRepositoryProvider);
    return _loadMenuData();
  }

  /// 🔹 Load all menu data (categories + items)
  Future<Menuinventorystate> _loadMenuData() async {
    try {
      final categories = await _menuRepository.getAllCategories();
      final menuItems = await _menuRepository.getAllMenuItems();

      return Menuinventorystate(
        categories: categories,
        menuItems: menuItems,
      );
    } catch (e, stack) {
      print("❌ Error loading menu data: $e");
      print(stack);
      // Return an empty state if something fails
      return Menuinventorystate(
        categories: const [],
        menuItems: const [],
      );
    }
  }

  /// 🔄 Refresh the menu (categories + items)
  Future<void> refreshMenu() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await _loadMenuData());
  }
}

/// ✅ Provider for MenuViewmodel
final menuViewModelProvider =
    AsyncNotifierProvider<MenuViewmodel, Menuinventorystate>(
  () => MenuViewmodel(),
);
