import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/ui/dashboard/viewmodels/all_orders_filter_notifier.dart';
import 'package:adminshahrayar/ui/dashboard/views/order_details_dialog.dart';
import 'package:adminshahrayar/ui/dashboard/views/pending_orders_page.dart';
import 'package:adminshahrayar/ui/orders/viewmodels/orders_notifier.dart';
import 'package:adminshahrayar/ui/orders/views/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class AllOrdersPage extends ConsumerWidget {
  const AllOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نراقب القائمة المفلترة
    final filteredOrders = ref.watch(filteredOrdersProvider);
    // نحتاج القائمة الكاملة للبحث
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
            // فلتر الأوامر
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
                  // استخدام القائمة المفلترة
                  rows: filteredOrders.map((order) {
                    return DataRow(
                      // ✅ تم إزالة onSelectChanged لإزالة الـ checkboxes
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

// Widget خاص بالفلاتر (DateFilter)
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
