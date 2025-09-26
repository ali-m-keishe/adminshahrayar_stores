import 'package:adminshahrayar/models/order.dart';
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

class OrdersNotifier extends StateNotifier<OrdersState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  OrdersNotifier() : super(OrdersState()) {
    _fetchOrders();
  }

  void _fetchOrders() {
    state = state.copyWith(orders: mockOrders);
  }

  void toggleView() {
    state = state.copyWith(isKanbanView: !state.isKanbanView);
  }

  Future<void> addNewOrder() async {
    await _audioPlayer.play(AssetSource('sounds/notification.mp3'));

    String newOrderId;
    if (state.orders.isEmpty) {
      newOrderId = '#85000';
    } else {
      newOrderId = '#${(int.parse(state.orders.first.id.substring(1)) + 1)}';
    }

    final newOrder = Order(
      id: newOrderId,
      customer: 'New Customer',
      items: [
        OrderItem(
            itemName: 'Special Burger',
            quantity: 1,
            modifiers: ['Extra bacon']),
        OrderItem(itemName: 'Onion Rings', quantity: 1),
      ],
      status: OrderStatus.Pending,
      // vvv THIS IS THE FIX vvv
      createdAt: DateTime.now(), // Use 'createdAt' instead of 'time'
      // ^^^ THIS IS THE FIX ^^^
      type: OrderType.Delivery,
    );

    state = state.copyWith(orders: [newOrder, ...state.orders]);
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier();
});
