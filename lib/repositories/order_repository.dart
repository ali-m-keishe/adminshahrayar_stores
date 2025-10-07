import '../models/order.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all orders
  Future<List<Order>> getAllOrders() async {
    try {
      final List<dynamic> response = await _supabase
          .from('orders')
          .select();

      print('Supabase fetch all orders: $response');

      return response
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Supabase fetch error orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(int id) async {
    try {
      final response =
          await _supabase.from('orders').select().eq('id', id).single();

      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return mockOrders.firstWhere((order) => order.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockOrders.where((order) => order.status == status).toList();
    }
  }

  // Get pending orders
  Future<List<Order>> getPendingOrders() async {
    return await getOrdersByStatus('Pending');
  }

  // Get preparing orders
  Future<List<Order>> getPreparingOrders() async {
    return await getOrdersByStatus('Preparing');
  }

  // Get completed orders
  Future<List<Order>> getCompletedOrders() async {
    return await getOrdersByStatus('Completed');
  }

  // Get cancelled orders
  Future<List<Order>> getCancelledOrders() async {
    return await getOrdersByStatus('Cancelled');
  }

  // Get recent orders
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sortedOrders = List<Order>.from(mockOrders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(limit).toList();
  }

  // Search orders by order ID
  Future<List<Order>> searchOrders(String query) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .ilike('id', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockOrders
          .where((order) => order.id.toString().contains(query))
          .toList();
    }
  }

  // Add new order
  Future<Order> addOrder(Order order) async {
    try {
      final response = await _supabase
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();

      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback behavior if Supabase fails
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Failed to add order: $e');
    }
  }

  // Update order
  Future<Order> updateOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the order
    return order;
  }

  // Update order status
  Future<Order> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select()
          .single();

      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback behavior if Supabase fails
      await Future.delayed(const Duration(milliseconds: 500));
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      final updatedOrder = Order(
        id: order.id,
        cartId: order.cartId,
        status: status,
        paymentToken: order.paymentToken,
        addressId: order.addressId,
        createdAt: order.createdAt,
      );

      return updatedOrder;
    }
  }

  // Assign driver to order
  Future<Order> assignDriverToOrder(int orderId, String driverId) async {
    try {
      final response = await _supabase
          .from('orders')
          .update({'driver_id': driverId})
          .eq('id', orderId)
          .select()
          .single();

      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      return order;
    }
  }

  // Delete order
  Future<void> deleteOrder(int id) async {
    try {
      await _supabase.from('orders').delete().eq('id', id);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('Failed to delete order: $e');
    }
  }

  // Get orders in date range
  Future<List<Order>> getOrdersInDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockOrders
        .where((order) =>
            order.createdAt.isAfter(startDate) &&
            order.createdAt.isBefore(endDate))
        .toList();
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final totalOrders = mockOrders.length;
    final statusCounts = <String, int>{};
    final typeCounts = <String, int>{};

    double totalRevenue = 0;

    for (final order in mockOrders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
      typeCounts['Order'] = (typeCounts['Order'] ?? 0) + 1;

      if (order.status == 'Completed') {
        totalRevenue += 0; // TODO: Calculate from cart items
      }
    }

    return {
      'totalOrders': totalOrders,
      'statusCounts': statusCounts,
      'typeCounts': typeCounts,
      'totalRevenue': totalRevenue,
      'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
    };
  }

  // Get orders requiring attention (pending and preparing)
  Future<List<Order>> getOrdersRequiringAttention() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockOrders
        .where((order) =>
            order.status == 'Pending' ||
            order.status == 'Preparing')
        .toList();
  }
}
