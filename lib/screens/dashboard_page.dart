import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/screens/main_screen.dart';
import 'package:adminshahrayar/screens/orders/orders_notifier.dart';
import 'package:adminshahrayar/screens/orders/widgets/order_details_dialog.dart';
import 'package:adminshahrayar/widget/order_status_badge.dart';
import 'package:adminshahrayar/widget/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Show Order Details Dialog
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
      return dateString; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (ordersResponse) {
        final allOrders = ordersResponse.orders;

        // ✅ فقط الطلبات اللي حالتها pending أو on the way
        final activeOrders = allOrders
            .where((order) =>
                order.status.toLowerCase() == 'pending' ||
                order.status.toLowerCase() == 'on the way')
            .toList();

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
                    onTap: () =>
                        ref.read(mainScreenIndexProvider.notifier).state = 3,
                  ),
                  StatCard(
                    title: 'Total Orders',
                    value: allOrders.length.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                    // 👇 عند الضغط نعرض صفحة جميع الطلبات (بما فيها done)
                    onTap: () =>
                        ref.read(mainScreenIndexProvider.notifier).state = 8,
                  ),
                  StatCard(
                    title: 'Active Orders',
                    value: activeOrders.length.toString(),
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
                    onTap: () =>
                        ref.read(mainScreenIndexProvider.notifier).state = 5,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ✅ جدول الطلبات النشطة فقط
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
                    rows: activeOrders.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(
                            InkWell(
                              onTap: () => _showOrderDetails(context, order),
                              child: Text(
                                order.id.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () => _showOrderDetails(context, order),
                              child: Text(
                                  _formatOrderDate(order.createdAt.toString())),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () => _showOrderDetails(context, order),
                              child: Text(order.cartId.toString()),
                            ),
                          ),
                          DataCell(
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: order.status.toLowerCase(),
                                dropdownColor: Colors.grey[900],
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                                style: const TextStyle(color: Colors.white),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'pending',
                                    child: Text('Pending',
                                        style: TextStyle(color: Colors.orange)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'on the way',
                                    child: Text('On the Way',
                                        style: TextStyle(color: Colors.blue)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'done',
                                    child: Text('Done',
                                        style: TextStyle(color: Colors.green)),
                                  ),
                                ],
                                onChanged: (newStatus) async {
                                  if (newStatus == null ||
                                      newStatus == order.status.toLowerCase())
                                    return;

                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title:
                                          const Text('Confirm Status Change'),
                                      content: Text(
                                        'Are you sure you want to change the status of order #${order.id} to "$newStatus"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    // ✅ Update in Supabase + Refresh UI
                                    await ref
                                        .read(ordersProvider.notifier)
                                        .updateOrderStatus(order.id, newStatus);

                                    // ✅ Optional success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Order #${order.id} status updated to "$newStatus".',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
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
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load orders.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(ordersProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
