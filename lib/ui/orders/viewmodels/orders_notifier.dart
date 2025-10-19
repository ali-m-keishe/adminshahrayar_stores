import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/data/repositories/order_repository.dart';
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
  final OrderRepository _orderRepository = OrderRepository();

  @override
  Future<OrdersState> build() async {
    final orders = await _orderRepository.getAllOrders();
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
