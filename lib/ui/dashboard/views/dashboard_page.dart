// import 'package:adminshahrayar/data/models/order.dart';
// import 'package:adminshahrayar/main_screen.dart';
// import 'package:adminshahrayar/ui/dashboard/viewmodels/dashboard_viewmodel.dart';
// import 'package:adminshahrayar/ui/dashboard/views/order_details_dialog.dart';
// import 'package:adminshahrayar/ui/dashboard/views/stat_card.dart';
// import 'package:adminshahrayar/ui/orders/viewmodels/orders_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';


// // Show Order Details Dialog
// void _showOrderDetails(BuildContext context, Order order) {
//   showDialog(
//     context: context,
//     builder: (context) => OrderDetailsDialog(order: order),
//   );
// }

// class DashboardPage extends ConsumerWidget {
//   const DashboardPage({super.key});

//   String _formatOrderDate(String dateString) {
//     try {
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
//     } catch (e) {
//       return dateString; // fallback if parsing fails
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final activeOrdersAsync = ref.watch(activeOrdersStreamProvider);
//     final dashboardState = ref.watch(
//       dashboardViewModelProvider.select((asyncState) => asyncState.whenData(
//             (state) => (
//               state.orders,
//               state.activeOrders,
//               state.customerNumber,
//               state.totalOrders,
//               state.totalRevenue,
//               state.deliveryOrders,
//             ),
//           )),
//     );
//     return dashboardState.when(
//       data: (tuple) {
//         final (
//           orders,
//           activeOrders,
//           customerNumber,
//           totalOrders,
//           totalRevenue,
//           deliveryOrders
//         ) = tuple;

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Dashboard',
//                 style: Theme.of(context)
//                     .textTheme
//                     .headlineMedium
//                     ?.copyWith(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 24),
//               Wrap(
//                 spacing: 24,
//                 runSpacing: 24,
//                 children: [
//                   StatCard(
//                     title: 'Total Revenue',
//                     value: totalRevenue.toStringAsFixed(2),
//                     icon: Icons.monetization_on,
//                     color: Colors.green,
//                     onTap: () =>
//                         ref.read(mainScreenIndexProvider.notifier).state = 2,
//                   ),
//                   StatCard(
//                     title: 'Total Orders',
//                     value: totalOrders.toString(),
//                     icon: Icons.shopping_cart,
//                     color: Colors.blue,
//                     // 👇 عند الضغط نعرض صفحة جميع الطلبات (بما فيها done)
//                     onTap: () =>
//                         ref.read(mainScreenIndexProvider.notifier).state = 8,
//                   ),
//                   StatCard(
//                     title: 'Active Orders',
//                     value: activeOrders.toString(),
//                     icon: Icons.hourglass_top,
//                     color: Colors.orange,
//                   ),
//                   StatCard(
//                     title: 'Delivery / Pickup',
//                     value: deliveryOrders.toString(),
//                     icon: Icons.local_shipping,
//                     color: Colors.teal,
//                   ),
//                   StatCard(
//                     title: 'Customers',
//                     value: customerNumber.toString(),
//                     icon: Icons.people,
//                     color: Colors.purple,
//                     onTap: () =>
//                         ref.read(mainScreenIndexProvider.notifier).state = 4,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               // ✅ جدول الطلبات النشطة فقط
//               Card(
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: DataTable(
//                     columns: const [
//                       DataColumn(label: Text('id')),
//                       DataColumn(label: Text('created_at')),
//                       DataColumn(label: Text('cart_id')),
//                       DataColumn(label: Text('status')),
//                       DataColumn(label: Text('payment_token')),
//                       DataColumn(label: Text('address_id')),
//                     ],
//                     rows: orders.map((order) {
//                       return DataRow(
//                         cells: [
//                           DataCell(
//                             InkWell(
//                               onTap: () => _showOrderDetails(context, order),
//                               child: Text(
//                                 order.id.toString(),
//                                 style: TextStyle(
//                                   color: Theme.of(context).primaryColor,
//                                   fontWeight: FontWeight.bold,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           DataCell(
//                             InkWell(
//                               onTap: () => _showOrderDetails(context, order),
//                               child: Text(
//                                   _formatOrderDate(order.createdAt.toString())),
//                             ),
//                           ),
//                           DataCell(
//                             InkWell(
//                               onTap: () => _showOrderDetails(context, order),
//                               child: Text(order.cartId.toString()),
//                             ),
//                           ),
//                           DataCell(
//                             DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: order.status.toLowerCase(),
//                                 dropdownColor: Colors.grey[900],
//                                 icon: const Icon(Icons.arrow_drop_down,
//                                     color: Colors.white),
//                                 style: const TextStyle(color: Colors.white),
//                                 items: const [
//                                   DropdownMenuItem(
//                                     value: 'pending',
//                                     child: Text('Pending',
//                                         style: TextStyle(color: Colors.orange)),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'on the way',
//                                     child: Text('On the Way',
//                                         style: TextStyle(color: Colors.blue)),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'done',
//                                     child: Text('Done',
//                                         style: TextStyle(color: Colors.green)),
//                                   ),
//                                 ],
//                                 onChanged: (newStatus) async {
//                                   if (newStatus == null ||
//                                       newStatus == order.status.toLowerCase()) {
//                                     return;
//                                   }

//                                   final confirmed = await showDialog<bool>(
//                                     context: context,
//                                     builder: (ctx) => AlertDialog(
//                                       title:
//                                           const Text('Confirm Status Change'),
//                                       content: Text(
//                                         'Are you sure you want to change the status of order #${order.id} to "$newStatus"?',
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () =>
//                                               Navigator.pop(ctx, false),
//                                           child: const Text('Cancel'),
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () =>
//                                               Navigator.pop(ctx, true),
//                                           child: const Text('Yes'),
//                                         ),
//                                       ],
//                                     ),
//                                   );

//                                   if (confirmed == true) {
//                                     // ✅ Update in Supabase + Refresh UI
//                                     await ref
//                                         .read(ordersProvider.notifier)
//                                         .updateOrderStatus(order.id, newStatus);

//                                     // ✅ Optional success message
//                                     if (!context.mounted) return;
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           'Order #${order.id} status updated to "$newStatus".',
//                                         ),
//                                         behavior: SnackBarBehavior.floating,
//                                         duration: const Duration(seconds: 2),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                           DataCell(
//                             InkWell(
//                               onTap: () => _showOrderDetails(context, order),
//                               child: Text(order.paymentToken),
//                             ),
//                           ),
//                           DataCell(
//                             InkWell(
//                               onTap: () => _showOrderDetails(context, order),
//                               child: Text(order.addressId.toString()),
//                             ),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//       loading: () => const Center(
//         child: Padding(
//           padding: EdgeInsets.all(40.0),
//           child: CircularProgressIndicator(),
//         ),
//       ),
//       error: (error, stackTrace) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(40.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 48),
//               const SizedBox(height: 12),
//               Text(
//                 'Failed to load orders.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.red.shade600,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 error.toString(),
//                 style: const TextStyle(color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: () => ref.refresh(ordersProvider),
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/main_screen.dart';
import 'package:adminshahrayar/ui/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:adminshahrayar/ui/dashboard/views/order_details_dialog.dart';
import 'package:adminshahrayar/ui/dashboard/views/stat_card.dart';
import 'package:adminshahrayar/ui/orders/viewmodels/orders_notifier.dart';
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
    // 👇 StreamProvider للـActive Orders
    final activeOrdersAsync = ref.watch(activeOrdersStreamProvider);

    // باقي الـDashboard stats
    final dashboardState = ref.watch(
      dashboardViewModelProvider.select((asyncState) => asyncState.whenData(
            (state) => (
              state.orders,
              state.activeOrders,
              state.customerNumber,
              state.totalOrders,
              state.totalRevenue,
              state.deliveryOrders,
            ),
          )),
    );

    return dashboardState.when(
      data: (tuple) {
        final (
          orders,
          activeOrders,
          customerNumber,
          totalOrders,
          totalRevenue,
          deliveryOrders
        ) = tuple;

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
                    value: totalOrders.toString(),
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

              // ✅ جدول الطلبات النشطة realtime
              Card(
                child: SizedBox(
                  width: double.infinity,
                  child: activeOrdersAsync.when(
                    data: (orders) {
                      return DataTable(
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
                              DataCell(Text(order.addressId.toString())),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, st) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(child: Text('Failed to load active orders: $err')),
                    ),
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