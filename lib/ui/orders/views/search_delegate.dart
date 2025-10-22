import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/ui/orders/views/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderSearchDelegate extends SearchDelegate<Order?> {
  final List<Order> allOrders;

  OrderSearchDelegate({required this.allOrders});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredOrders = allOrders.where((order) {
      return order.id.toString().contains(query) ||
          order.status.toLowerCase().contains(query.toLowerCase()) ||
          order.paymentToken.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return ListTile(
          title: Text('Order #${order.id}'),
          subtitle: Text(
              'Status: ${order.status} - ${timeago.format(order.createdAt)}'),
          trailing: OrderStatusBadge.fromString(order.status),
          onTap: () {
            close(context, order);
          },
        );
      },
    );
  }
}
