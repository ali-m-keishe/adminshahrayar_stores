import 'package:adminshahrayar_stores/data/models/order.dart';
import 'package:flutter/material.dart';

class OrderSearchDelegate extends SearchDelegate<Order?> {
  final List<Order> allOrders;

  OrderSearchDelegate({required this.allOrders});

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Builds the 'clear' button on the right of the search bar
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Builds the 'back' button on the left of the search bar
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Closes the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Builds the results after the user submits a search (we'll just reuse suggestions)
    return _buildFilteredList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Builds the suggestions as the user types
    return _buildFilteredList();
  }

  Widget _buildFilteredList() {
    final queryLower = query.toLowerCase();

    // The actual filtering logic
    final filteredOrders = allOrders.where((order) {
      final idMatches = order.id.toString().toLowerCase().contains(queryLower);
      final customerMatches =
          order.cartId.toString().toLowerCase().contains(queryLower);
      return idMatches || customerMatches;
    }).toList();

    if (filteredOrders.isEmpty && query.isNotEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return ListTile(
          leading:
              CircleAvatar(child: Text(order.id.toString().substring(1, 3))),
          title: Text('Order ${order.id}'),
          subtitle: Text('Cart ${order.cartId}'),
          trailing:
              const Text('\$0.00'), // TODO: compute from cart_items by cartId
          onTap: () {
            // When a result is tapped, close the search and return the order
            // When a result is tapped, close the search and return the order
            close(context, order);
          },
        );
      },
    );
  }
}
