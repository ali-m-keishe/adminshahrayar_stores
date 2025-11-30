import 'dart:async';
import 'package:adminshahrayar_stores/data/models/dashboard_state.dart';
import 'package:adminshahrayar_stores/data/models/order.dart';
import 'package:adminshahrayar_stores/data/repositories/analytic_repository.dart';
import 'package:adminshahrayar_stores/data/repositories/customer_repository.dart';
import 'package:adminshahrayar_stores/data/repositories/order_repository.dart';
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
    
    // Load initial dashboard state with first page of orders
    return await _loadDashboardWithFirstPage();
  }

  /// 🔹 Load dashboard with first page of orders already loaded
  Future<DashboardState> _loadDashboardWithFirstPage() async {
    try {
      // Load all dashboard stats
      final carts = await analyticsRepository.getAllCarts();
      double totalRevenue =
          carts.fold(0.0, (sum, cart) => sum + cart.totalPrice);

      final customers = await customerRepository.getAllCustomers();
      final customerNumber = customers.length;

      final orders = await orderRepository.getAllOrders();
      final totalOrders = orders.length;

      // Get active orders count only
      final activeOrdersResult = await orderRepository.getPendingAndOnTheWayOrdersWithCount();
      final activeOrdersTotalCount = activeOrdersResult['totalCount'] as int;
      print("Total active orders count: $activeOrdersTotalCount");

      // Load first page of active orders immediately
      final paginatedResult = await orderRepository.getPaginatedActiveOrders(
        limit: 5,
        offset: 0,
      );
      final activeOrders = paginatedResult['orders'] as List<Order>;
      print("✅ Loaded ${activeOrders.length} orders on first page");
  
      final deliveryOrders = await orderRepository.getOnTheWayOrders();
   
      return DashboardState(
        totalRevenue: totalRevenue,
        customerNumber: customerNumber,
        totalOrders: totalOrders,
        activeOrders: activeOrdersTotalCount,
        deliveryOrders: deliveryOrders.length,
        orders: activeOrders, // ✅ First 5 orders loaded immediately
        totalActiveOrdersCount: activeOrdersTotalCount,
      );
    } catch (e) {
      print("Error loading dashboard: $e");

      return DashboardState(
        totalRevenue: 0.0,
        customerNumber: 0,
        totalOrders: 0,
        activeOrders: 0,
        deliveryOrders: 0,
        orders: const [],
        totalActiveOrdersCount: 0,
      );
    }
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

      // Get active orders count only (orders will be loaded via pagination)
      final activeOrdersResult = await orderRepository.getPendingAndOnTheWayOrdersWithCount();
      final activeOrdersTotalCount = activeOrdersResult['totalCount'] as int;
      print("Total active orders count: $activeOrdersTotalCount");

      final deliveryOrders = await orderRepository.getOnTheWayOrders();


      return DashboardState(
        totalRevenue: totalRevenue,
        customerNumber: customerNumber,
        totalOrders: totalOrders,
        activeOrders: activeOrdersTotalCount,
        deliveryOrders: deliveryOrders.length,
        orders: const <Order>[], // Empty initially, will be loaded via pagination
        totalActiveOrdersCount: activeOrdersTotalCount,
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
        totalActiveOrdersCount: 0,
      );
    }
  }

  /// 🔹 Load paginated active orders
  Future<void> loadPaginatedActiveOrders({
    required int limit,
    required int offset,
  }) async {
    try {
      // If state is loading or null, don't update
      final currentState = state.value;
      if (currentState == null) {
        print("⚠️ Cannot load paginated orders: state is null");
        return;
      }

      // Fetch paginated active orders
      final result = await orderRepository.getPaginatedActiveOrders(
        limit: limit,
        offset: offset,
      );

      final orders = result['orders'] as List<Order>;
      final totalCount = result['totalCount'] as int;

      // Update state with paginated orders
      state = AsyncValue.data(
        currentState.copyWith(
          orders: orders,
          totalActiveOrdersCount: totalCount,
          activeOrders: totalCount, // Update active orders count too
        ),
      );
    } catch (e, stack) {
      print("❌ Error loading paginated active orders: $e");
      print(stack);
      // Don't set error state, just log it
    }
  }

  /// 🔹 Refresh stats only (without affecting pagination)
  Future<void> refreshStats() async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      // Refresh only the stats
      final carts = await analyticsRepository.getAllCarts();
      double totalRevenue =
          carts.fold(0.0, (sum, cart) => sum + cart.totalPrice);

      final customers = await customerRepository.getAllCustomers();
      final customerNumber = customers.length;

      final orders = await orderRepository.getAllOrders();
      final totalOrders = orders.length;

      final deliveryOrders = await orderRepository.getOnTheWayOrders();

      state = AsyncValue.data(
        currentState.copyWith(
          totalRevenue: totalRevenue,
          customerNumber: customerNumber,
          totalOrders: totalOrders,
          deliveryOrders: deliveryOrders.length,
        ),
      );
    } catch (e, stack) {
      print("❌ Error refreshing stats: $e");
      print(stack);
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



















