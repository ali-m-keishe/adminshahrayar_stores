import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/ui/dashboard/viewmodels/all_orders_filter_notifier.dart';
import 'package:adminshahrayar/ui/dashboard/views/order_details_dialog.dart';
import 'package:adminshahrayar/ui/orders/viewmodels/orders_notifier.dart';
import 'package:adminshahrayar/ui/orders/views/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class PendingOrdersPage extends ConsumerWidget {
  const PendingOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered provider for pending and on-the-way orders
    final pendingOrders = ref.watch(pendingAndOnTheWayOrdersProvider);
    // We still need the full list for the search delegate
    final allOrders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending & On The Way Orders'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Orders',
            onPressed: () async {
              final selectedOrder = await showSearch<Order?>(
                context: context,
                delegate: OrderSearchDelegate(allOrders: allOrders),
              );

              if (context.mounted && selectedOrder != null) {
                _showOrderDetails(context, selectedOrder);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status filter info
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing ${pendingOrders.length} orders that are pending or on the way',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('id')),
                    DataColumn(label: Text('created_at')),
                    DataColumn(label: Text('cart_id')),
                    DataColumn(label: Text('status')),
                    DataColumn(label: Text('payment_token')),
                    DataColumn(label: Text('address_id')),
                  ],
                  // Use the filtered list to build the rows
                  rows: pendingOrders.map((order) {
                    return DataRow(
                      // REMOVED onSelectChanged to eliminate checkboxes
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(
                              order.id.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(timeago.format(order.createdAt)),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(order.cartId.toString()),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: OrderStatusBadge.fromString(order.status),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(order.paymentToken),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () => _showOrderDetails(context, order),
                            child: Text(order.addressId.toString()),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }
}

// Reuse the existing OrderSearchDelegate
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
