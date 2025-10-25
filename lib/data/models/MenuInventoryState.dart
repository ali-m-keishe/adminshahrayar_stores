
import 'package:adminshahrayar/data/models/category.dart';
import 'package:adminshahrayar/data/models/menu_item.dart';

class Menuinventorystate {
 late final List<Category> categories;
 late final List<MenuItem> menuItems;

  Menuinventorystate({
    this.categories = const [],
    this.menuItems = const [],
  });

  Menuinventorystate copyWith({
    List<Category>? categories,
    List<MenuItem>? menuItems,
  }) {
    return Menuinventorystate(
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
    );
  }
}