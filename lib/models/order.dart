// The OrderItem class MUST be defined here like this.
// This will fix the errors related to 'itemName', 'quantity', and 'modifiers'.
class OrderItem {
  final String itemName;
  final int quantity;
  final List<String> modifiers;

  OrderItem({
    required this.itemName,
    required this.quantity,
    this.modifiers = const [],
  });
}

enum OrderStatus { Pending, Preparing, Completed, Cancelled }

enum OrderType { Pickup, Delivery }

class Order {
  final String id;
  final String customer;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt; // It must be 'createdAt' of type DateTime
  final OrderType type;
  final String? driverId;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.status,
    required this.createdAt, // not 'time'
    required this.type,
    this.driverId,
  });

  double get total {
    return items.fold(0, (sum, item) => sum + (item.quantity * 15.50));
  }
}

// Mock data using the correct structure
final List<Order> mockOrders = [
  Order(
      id: '#84321',
      customer: 'John Doe',
      items: [OrderItem(itemName: 'Margherita Pizza', quantity: 1)],
      status: OrderStatus.Completed,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      type: OrderType.Delivery,
      driverId: null),
  Order(
      id: '#84320',
      customer: 'Jane Smith',
      items: [OrderItem(itemName: 'Classic Burger', quantity: 2)],
      status: OrderStatus.Pending,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      type: OrderType.Pickup),
  Order(
      id: '#84319',
      customer: 'Peter Jones',
      items: [OrderItem(itemName: 'Caesar Salad', quantity: 1)],
      status: OrderStatus.Completed,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      type: OrderType.Pickup),
  Order(
      id: '#84318',
      customer: 'Mary Johnson',
      items: [OrderItem(itemName: 'Spaghetti Carbonara', quantity: 1)],
      status: OrderStatus.Completed,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      type: OrderType.Delivery,
      driverId: 'd2'),
  Order(
      id: '#84317',
      customer: 'Chris Lee',
      items: [OrderItem(itemName: 'Chocolate Lava Cake', quantity: 2)],
      status: OrderStatus.Cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
      type: OrderType.Delivery),
];
