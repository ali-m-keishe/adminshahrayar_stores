import 'dart:async';
import 'package:adminshahrayar/data/models/dashboard_state.dart';
import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/data/repositories/analytic_repository.dart';
import 'package:adminshahrayar/data/repositories/customer_repository.dart';
import 'package:adminshahrayar/data/repositories/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardViewmodel extends AsyncNotifier<DashboardState> {
  late final AnalyticsRepository analyticsRepository;
  late final CustomerRepository customerRepository;
  late final OrderRepository orderRepository;
  @override
  FutureOr<DashboardState> build() async {
    analyticsRepository = ref.read(analyticsRepositoryProvider);
    customerRepository = ref.read(customerRepositoryProvider);
    orderRepository = ref.read(orderRepositoryProvider);
    return _loadDashboard();
  }

  /// 🔹 تحميل بيانات الداشبورد (إجمالي الإيرادات، عدد العملاء، الطلبات...)
  Future<DashboardState> _loadDashboard() async {
    try {
      // نجيب كل البيانات من الـ Repository
      final carts = await analyticsRepository.getAllCarts();
      double totalRevenue =
          carts.fold(0.0, (sum, cart) => sum + cart.totalPrice);

      final customers = await customerRepository.getAllCustomers();
      final customerNumber = customers.length;

      final orders = await orderRepository.getAllOrders();
      final totalOrders = orders.length;

      final activeOrders = await orderRepository.getPendingAndOnTheWayOrders();

      final deliveryOrders = await orderRepository.getOnTheWayOrders();

      return DashboardState(
        totalRevenue: totalRevenue,
        customerNumber: customerNumber,
        totalOrders: totalOrders,
        activeOrders: activeOrders.length,
        deliveryOrders: deliveryOrders.length,
        orders: activeOrders,
      );
    } catch (e) {
      print("Error loading dashboard: $e");

      // في حالة الخطأ نرجع DashboardState فاضي
      return DashboardState(
        totalRevenue: 0.0,
        customerNumber: 0,
        totalOrders: 0,
        activeOrders: 0,
        deliveryOrders: 0,
        orders: const [],
      );
    }
  }

  /// 🔄 لتحديث بيانات الداشبورد يدوياً (refresh)
  Future<void> refreshDashboard() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadDashboard());
  }
}

/// ✅ Provider
final dashboardViewModelProvider =
    AsyncNotifierProvider<DashboardViewmodel, DashboardState>(
  () => DashboardViewmodel(),
);



final activeOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return repo.subscribeToActiveOrders();
});



















