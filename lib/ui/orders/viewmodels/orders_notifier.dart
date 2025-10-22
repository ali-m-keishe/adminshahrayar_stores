import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/data/repositories/order_repository.dart';
import 'package:adminshahrayar/ui/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

class OrdersState {
  final bool isKanbanView;
  final List<Order> orders;

  OrdersState({this.isKanbanView = true, this.orders = const []});

  OrdersState copyWith({bool? isKanbanView, List<Order>? orders}) {
    return OrdersState(
      isKanbanView: isKanbanView ?? this.isKanbanView,
      orders: orders ?? this.orders,
    );
  }
}

class OrdersNotifier extends AsyncNotifier<OrdersState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final OrderRepository _orderRepository;
  late final DashboardViewmodel dashboardViewModel;
  @override
  Future<OrdersState> build() async {
    _orderRepository = ref.read(orderRepositoryProvider);
    final orders = await _orderRepository.getAllOrders();
    dashboardViewModel =
        ref.read(dashboardViewModelProvider.notifier); // Refresh dashboard data

    return OrdersState(orders: orders);
  }

  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await build());
  }

  void toggleView() {
    final current = state.valueOrNull ?? OrdersState();
    final updated = current.copyWith(isKanbanView: !current.isKanbanView);
    state = AsyncData(updated);
  }

  Future<void> addNewOrder() async {
    await _audioPlayer.play(AssetSource('sounds/notification.mp3'));

    int newOrderId;
    final current = state.valueOrNull ?? OrdersState();
    if (current.orders.isEmpty) {
      newOrderId = 85000;
    } else {
      newOrderId = current.orders.first.id + 1;
    }

    final newOrder = Order(
      id: newOrderId,
      cartId: 1,
      status: 'Pending',
      paymentToken: 'tok_${DateTime.now().millisecondsSinceEpoch}',
      addressId: 1,
      createdAt: DateTime.now(),
    );

    try {
      await _orderRepository.addOrder(newOrder);
      await refreshOrders(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      await refreshOrders(); // Refresh the data
      await dashboardViewModel.refreshDashboard(); // Refresh dashboard data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> assignDriverToOrder(int orderId, String driverId) async {
    try {
      await _orderRepository.assignDriverToOrder(orderId, driverId);
      await refreshOrders(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, OrdersState>(() {
  return OrdersNotifier();
});

// 1. Define the different filter options
enum DateFilter { All, Today, LastWeek, LastMonth, LastYear }

// 2. Create a simple notifier to hold the currently selected filter
class AllOrdersFilterNotifier extends StateNotifier<DateFilter> {
  AllOrdersFilterNotifier() : super(DateFilter.All);

  void setFilter(DateFilter filter) {
    state = filter;
  }
}

// 3. Create a provider for our new notifier
final allOrdersFilterProvider =
    StateNotifierProvider<AllOrdersFilterNotifier, DateFilter>((ref) {
  return AllOrdersFilterNotifier();
});

// 4. Create the final "filtered" provider
// This provider cleverly watches BOTH the main orders list and the filter provider.
// If either one changes, it will re-run its logic and provide a new, filtered list to the UI.
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final filter = ref.watch(allOrdersFilterProvider);
  final orders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];
  final now = DateTime.now();

  switch (filter) {
    case DateFilter.Today:
      return orders
          .where((order) =>
              order.createdAt.year == now.year &&
              order.createdAt.month == now.month &&
              order.createdAt.day == now.day)
          .toList();
    case DateFilter.LastWeek:
      return orders
          .where((order) =>
              order.createdAt.isAfter(now.subtract(const Duration(days: 7))))
          .toList();
    case DateFilter.LastMonth:
      return orders
          .where((order) =>
              order.createdAt.isAfter(now.subtract(const Duration(days: 30))))
          .toList();
    case DateFilter.LastYear:
      return orders
          .where((order) =>
              order.createdAt.isAfter(now.subtract(const Duration(days: 365))))
          .toList();
    case DateFilter.All:
      return orders;
  }
});

// 5. Create a provider for filtering orders by status (pending and on the way)
// final pendingAndOnTheWayOrdersProvider = Provider<List<Order>>((ref) {
//   final orders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];

//   return orders
//       .where((order) =>
//           order.status.toLowerCase() == 'pending' ||
//           order.status.toLowerCase() == 'on the way')
//       .toList();
// });
