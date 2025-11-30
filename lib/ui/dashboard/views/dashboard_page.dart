import 'package:adminshahrayar_stores/data/models/order.dart';
import 'package:adminshahrayar_stores/main_screen.dart';
import 'package:adminshahrayar_stores/ui/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:adminshahrayar_stores/ui/dashboard/views/order_details_dialog.dart';
import 'package:adminshahrayar_stores/ui/dashboard/views/stat_card.dart';
import 'package:adminshahrayar_stores/ui/orders/viewmodels/orders_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adminshahrayar_stores/ui/orders/views/address_details_dialog.dart';

// Show Order Details Dialog
void _showOrderDetails(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (context) => OrderDetailsDialog(order: order),
  );
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int currentPage = 0;
  final int ordersPerPage = 5;

  @override
  void initState() {
    super.initState();
    // Note: First page is loaded automatically in the ViewModel's build() method
  }

  void _loadPage() {
    final viewModel = ref.read(dashboardViewModelProvider.notifier);
    final offset = currentPage * ordersPerPage;
    viewModel.loadPaginatedActiveOrders(
      limit: ordersPerPage, // Use ordersPerPage (currently 5)
      offset: offset,
    );
  }

  void _onPageChanged(int newPage) {
    setState(() {
      currentPage = newPage;
    });
    _loadPage();
  }

  String _formatOrderDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateString; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // باقي الـDashboard stats
    final dashboardState = ref.watch(dashboardViewModelProvider);

    return dashboardState.when(
      data: (state) {
        final orders = state.orders;
        final activeOrders = state.activeOrders;
        final customerNumber = state.customerNumber;
        final totalOrders = state.totalOrders;
        final totalRevenue = state.totalRevenue;
        final deliveryOrders = state.deliveryOrders;
        final totalActiveOrdersCount = state.totalActiveOrdersCount;

        // Calculate total pages based on server-side count
        final totalPages = (totalActiveOrdersCount / ordersPerPage).ceil().clamp(1, 999999);

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
                    value: totalRevenue.toStringAsFixed(2),
                    icon: Icons.monetization_on,
                    color: Colors.green,
                    onTap: () =>
                        ref.read(mainScreenIndexProvider.notifier).state = 2,
                  ),
                  StatCard(
                    title: 'Total Orders',
                    value: totalOrders.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                    onTap: () =>
                        ref.read(mainScreenIndexProvider.notifier).state = 8,
                  ),
                  StatCard(
                    title: 'Active Orders',
                    value: activeOrders.toString(),
                    icon: Icons.hourglass_top,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: 'Delivery / Pickup',
                    value: deliveryOrders.toString(),
                    icon: Icons.local_shipping,
                    color: Colors.teal,
                  ),
                  StatCard(
                    title: 'Customers',
                    value: customerNumber.toString(),
                    icon: Icons.people,
                    color: Colors.purple,
                    onTap: () =>
                        ref.read(mainScreenIndexProvider.notifier).state = 4,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ جدول الطلبات النشطة مع الـ pagination
              Card(
                child: Column(
                  children: [
                    SizedBox(
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
                        rows: orders.map((order) {
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
                                  child: Text(_formatOrderDate(order.createdAt.toString())),
                                ),
                              ),
                              DataCell(Text(order.cartId.toString())),
                              DataCell(
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: order.status.toLowerCase(),
                                    dropdownColor: Colors.grey[900],
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                    style: const TextStyle(color: Colors.white),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'pending',
                                        child: Text('Pending', style: TextStyle(color: Colors.orange)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'on the way',
                                        child: Text('On the Way', style: TextStyle(color: Colors.blue)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'done',
                                        child: Text('Done', style: TextStyle(color: Colors.green)),
                                      ),
                                    ],
                                    onChanged: (newStatus) async {
                                      if (newStatus == null || newStatus == order.status.toLowerCase()) return;

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Confirm Status Change'),
                                          content: Text('Are you sure you want to change the status of order #${order.id} to "$newStatus"?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        await ref.read(ordersProvider.notifier).updateOrderStatus(order.id, newStatus);
                                        _loadPage(); // Refresh current page after status update
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Order #${order.id} status updated to "$newStatus".'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              DataCell(Text(order.paymentToken)),
                              DataCell(
                                InkWell(
                                  onTap: order.addressId != null && order.addressId != 0
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AddressDetailsDialog(addressId: order.addressId!),
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    order.addressId == null || order.addressId == 0
                                        ? 'Address is empty or deleted'
                                        : (order.addressFormatted ?? 'Address #${order.addressId}'),
                                    style: TextStyle(
                                      color: (order.addressId == null || order.addressId == 0)
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    // Pagination controls
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: currentPage > 0
                                  ? () => _onPageChanged(currentPage - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text('Page ${currentPage + 1} of $totalPages'),
                            IconButton(
                              onPressed: currentPage < totalPages - 1
                                  ? () => _onPageChanged(currentPage + 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
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