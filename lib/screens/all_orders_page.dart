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
    final allOrders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];

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
                    DataColumn(label: Text('id')),
                    DataColumn(label: Text('created_at')),
                    DataColumn(label: Text('cart_id')),
                    DataColumn(label: Text('status')),
                    DataColumn(label: Text('payment_token')),
                    DataColumn(label: Text('address_id')),
                  ],
                  // Use the filtered list to build the rows
                  rows: filteredOrders.map((order) {
                    return DataRow(cells: [
                      DataCell(Text(order.id.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(timeago.format(order.createdAt))),
                      DataCell(Text(order.cartId.toString())),
                      DataCell(OrderStatusBadge.fromString(order.status)),
                      DataCell(Text(order.paymentToken)),
                      DataCell(Text(order.addressId.toString())),
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
