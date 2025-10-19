import 'order.dart';
import 'cart.dart';
import 'menu_item.dart';
import 'item_size.dart';
import 'addon.dart';

class OrderDetails {
  final Order order;
  final Cart cart;
  final List<OrderItemDetails> items;
  final double totalPrice;

  OrderDetails({
    required this.order,
    required this.cart,
    required this.items,
    required this.totalPrice,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      order: Order.fromJson(json['order']),
      cart: Cart.fromJson(json['cart']),
      items: (json['items'] as List)
          .map((item) => OrderItemDetails.fromJson(item))
          .toList(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      'cart': cart.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'total_price': totalPrice,
    };
  }
}

class OrderItemDetails {
  final CartItem cartItem;
  final MenuItem menuItem;
  final ItemSize? size;
  final List<Addon> addons;

  OrderItemDetails({
    required this.cartItem,
    required this.menuItem,
    this.size,
    required this.addons,
  });

  factory OrderItemDetails.fromJson(Map<String, dynamic> json) {
    return OrderItemDetails(
      cartItem: CartItem.fromJson(json['cart_item']),
      menuItem: MenuItem.fromJson(json['menu_item']),
      size: json['size'] != null ? ItemSize.fromJson(json['size']) : null,
      addons: (json['addons'] as List)
          .map((addon) => Addon.fromJson(addon))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item': cartItem.toJson(),
      'menu_item': menuItem.toJson(),
      'size': size?.toJson(),
      'addons': addons.map((addon) => addon.toJson()).toList(),
    };
  }

  /// ✅ Helper method to get total price for this order item
  /// Includes base item price, size additional price, and addons
  double get itemTotalPrice {
    double basePrice = cartItem.price;

    // Add size additional price if exists
    if (size != null) {
      basePrice += size!.additionalPrice;
    }

    // Add total addon prices
    double addonsTotal = addons.fold(0.0, (sum, addon) => sum + addon.price);

    // Multiply by quantity
    return (basePrice + addonsTotal) * cartItem.quantity;
  }

  /// ✅ Display item name (with size if applicable)
  String get displayName {
    if (size != null) {
      return '${menuItem.name} (${size!.sizeName})';
    }
    return menuItem.name;
  }

  /// ✅ Get all addon names as comma-separated text
  String get addonNames {
    if (addons.isEmpty) return '';
    return addons.map((addon) => addon.name).join(', ');
  }
}
