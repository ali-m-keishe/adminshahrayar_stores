import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/screens/main_screen.dart';
import 'package:adminshahrayar/screens/orders/orders_notifier.dart';
import 'package:adminshahrayar/screens/orders/widgets/order_details_dialog.dart';
import 'package:adminshahrayar/widget/order_status_badge.dart';
import 'package:adminshahrayar/widget/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago; // 1. ADD THIS IMPORT

void _showOrderDetails(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (context) => OrderDetailsDialog(order: order),
  );
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  String _formatOrderDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateString; // في حالة فشل التحويل، ارجع النص الأصلي
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];
    final recentOrders = allOrders.toList();

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
                  DataColumn(label: Text('id')),
                  DataColumn(label: Text('created_at')),
                  DataColumn(label: Text('cart_id')),
                  DataColumn(label: Text('status')),
                  DataColumn(label: Text('payment_token')),
                  DataColumn(label: Text('address_id')),
                ],
                rows: recentOrders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(Text(order.id.toString(),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold))),
                      DataCell(Text(_formatOrderDate(order.createdAt.toString()))),
                      DataCell(Text(order.cartId.toString())),
                      DataCell(OrderStatusBadge.fromString(order.status)),
                      DataCell(Text(order.paymentToken)),
                      DataCell(Text(order.addressId.toString())),
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
