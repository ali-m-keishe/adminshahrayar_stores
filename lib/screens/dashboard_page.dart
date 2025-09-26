import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/screens/main_screen.dart';
import 'package:adminshahrayar/screens/orders/orders_notifier.dart';
import 'package:adminshahrayar/screens/orders/widgets/order_details_dialog.dart';
import 'package:adminshahrayar/widget/order_status_badge.dart';
import 'package:adminshahrayar/widget/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago; // 1. ADD THIS IMPORT

void _showOrderDetails(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (context) => OrderDetailsDialog(order: order),
  );
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider).orders;
    final recentOrders = allOrders.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              StatCard(
                title: 'Total Revenue',
                value: '\$12,450',
                icon: Icons.monetization_on,
                color: Colors.green,
                onTap: () => ref.read(mainScreenIndexProvider.notifier).state =
                    3, // Analytics
              ),
              StatCard(
                title: 'Total Orders',
                value: '789',
                icon: Icons.shopping_cart,
                color: Colors.blue,
                onTap: () => ref.read(mainScreenIndexProvider.notifier).state =
                    9, // AllOrdersPage
              ),
              const StatCard(
                title: 'Active Orders',
                value: '23',
                icon: Icons.hourglass_top,
                color: Colors.orange,
              ),
              const StatCard(
                title: 'Delivery / Pickup',
                value: '15 / 8',
                icon: Icons.local_shipping,
                color: Colors.teal,
              ),
              StatCard(
                title: 'Customers',
                value: '450',
                icon: Icons.people,
                color: Colors.purple,
                onTap: () => ref.read(mainScreenIndexProvider.notifier).state =
                    5, // Customers
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Time')),
                ],
                rows: recentOrders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(order.id,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                        onTap: () => _showOrderDetails(context, order),
                      ),
                      DataCell(Text(order.customer)),
                      DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                      DataCell(OrderStatusBadge(status: order.status)),
                      DataCell(Text(order.type.name)),
                      // 2. THIS IS THE FIX
                      DataCell(Text(timeago.format(order.createdAt))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
