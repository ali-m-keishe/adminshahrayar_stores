
import 'package:adminshahrayar_stores/data/models/category.dart';
import 'package:adminshahrayar_stores/data/models/menu_item.dart';
import 'package:adminshahrayar_stores/data/models/attribute.dart';

class Menuinventorystate {
 late final List<Category> categories;
 late final List<MenuItem> menuItems;
 late final List<Attribute> attributes;
 late final int totalMenuItemsCount;

  Menuinventorystate({
    this.categories = const [],
    this.menuItems = const [],
    this.attributes = const [],
    this.totalMenuItemsCount = 0,
  });

  Menuinventorystate copyWith({
    List<Category>? categories,
    List<MenuItem>? menuItems,
    List<Attribute>? attributes,
    int? totalMenuItemsCount,
  }) {
    return Menuinventorystate(
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
      attributes: attributes ?? this.attributes,
      totalMenuItemsCount: totalMenuItemsCount ?? this.totalMenuItemsCount,
    );
  }
}