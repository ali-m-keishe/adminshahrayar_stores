
import 'package:adminshahrayar/data/models/category.dart';
import 'package:adminshahrayar/data/models/menu_item.dart';
import 'package:adminshahrayar/data/models/addon.dart';

class Menuinventorystate {
 late final List<Category> categories;
 late final List<MenuItem> menuItems;
 late final List<Addon> addons;
 late final int totalMenuItemsCount;

  Menuinventorystate({
    this.categories = const [],
    this.menuItems = const [],
    this.addons = const [],
    this.totalMenuItemsCount = 0,
  });

  Menuinventorystate copyWith({
    List<Category>? categories,
    List<MenuItem>? menuItems,
    List<Addon>? addons,
    int? totalMenuItemsCount,
  }) {
    return Menuinventorystate(
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      addons: addons ?? this.addons,
      totalMenuItemsCount: totalMenuItemsCount ?? this.totalMenuItemsCount,
    );
  }
}