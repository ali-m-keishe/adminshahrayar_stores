import 'package:adminshahrayar/data/models/order.dart';

class DashboardState {
  final double totalRevenue;
  final int customerNumber;
  final int totalOrders;
  final int activeOrders;
  final int deliveryOrders;
  final List<Order> orders;

  const DashboardState({
    required this.totalRevenue,
    required this.customerNumber,
    required this.totalOrders,
    required this.activeOrders,
    required this.deliveryOrders,
    this.orders = const [],
  });

  DashboardState copyWith({
    double? totalRevenue,
    int? customerNumber,
    int? totalOrders,
    int? activeOrders,
    int? deliveryOrders,
    List<Order>? orders,
  }) {
    return DashboardState(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      customerNumber: customerNumber ?? this.customerNumber,
      totalOrders: totalOrders ?? this.totalOrders,
      activeOrders: activeOrders ?? this.activeOrders,
      deliveryOrders: deliveryOrders ?? this.deliveryOrders,
      orders: orders ?? this.orders,
    );
  }
}
