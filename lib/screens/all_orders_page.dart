import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/screens/all_orders/all_orders_filter_notifier.dart';
import 'package:adminshahrayar/screens/all_orders/order_search_delegate.dart';
import 'package:adminshahrayar/screens/orders/orders_notifier.dart';
import 'package:adminshahrayar/screens/orders/widgets/order_details_dialog.dart';
import 'package:adminshahrayar/widget/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllOrdersPage extends ConsumerWidget {
  const AllOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We now watch our NEW filtered provider for the list to display
    final filteredOrders = ref.watch(filteredOrdersProvider);
    // We still need the full list for the search delegate
    final allOrders = ref.watch(ordersProvider).orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
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
            // ADDED THE FILTER CHIPS WIDGET
            const _FilterChips(),
            const SizedBox(height: 16),
            Card(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Actions')),
                  ],
                  // Use the filtered list to build the rows
                  rows: filteredOrders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order.id,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(order.customer)),
                      // Use the timeago package to format the date
                      DataCell(Text(timeago.format(order.createdAt))),
                      DataCell(Chip(
                        label: Text(order.type.name),
                        backgroundColor: order.type == OrderType.Delivery
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.purple.withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: order.type == OrderType.Delivery
                                ? Colors.blue.shade800
                                : Colors.purple.shade800,
                            fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      )),
                      DataCell(OrderStatusBadge(status: order.status)),
                      DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: 'View Details',
                          onPressed: () => _showOrderDetails(context, order),
                        ),
                      ),
                    ]);
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

// A new widget for the filter chips to keep the build method clean
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(allOrdersFilterProvider);
    return Wrap(
      spacing: 8.0,
      children: DateFilter.values.map((filter) {
        return ChoiceChip(
          label: Text(filter.name),
          selected: selectedFilter == filter,
          onSelected: (isSelected) {
            if (isSelected) {
              ref.read(allOrdersFilterProvider.notifier).setFilter(filter);
            }
          },
        );
      }).toList(),
    );
  }
}
