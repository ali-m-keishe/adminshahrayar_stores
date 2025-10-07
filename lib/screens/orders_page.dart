import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/screens/orders/orders_notifier.dart';
import 'package:adminshahrayar/screens/orders/widgets/order_details_dialog.dart';
import 'package:adminshahrayar/widget/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The main widget is a ConsumerWidget
class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We 'watch' the provider to get the current state.
    // The widget will automatically rebuild when this state changes.
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load orders: $e')),
      data: (ordersState) {
        final isKanbanView = ordersState.isKanbanView;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kitchen Order Flow',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // This button calls the method on our notifier
                  ElevatedButton(
                    onPressed: () {
                      ref.read(ordersProvider.notifier).addNewOrder();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text('Simulate New Order'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    // The icon and label now depend on the state from the notifier
                    icon: Icon(
                        isKanbanView ? Icons.table_rows : Icons.view_kanban),
                    label: Text(isKanbanView ? 'Table View' : 'Kanban View'),
                    onPressed: () {
                      // This button also calls a method on the notifier
                      ref.read(ordersProvider.notifier).toggleView();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // We conditionally show the Kanban or Table view based on the state
          if (isKanbanView)
            _KanbanView(orders: ordersState.orders)
          else
            _TableView(orders: ordersState.orders),
        ],
      ),
    );
      },
    );
  }
}

// Helper function to show the dialog, keeping the build method clean
void _showOrderDetails(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (context) => OrderDetailsDialog(order: order),
  );
}

// The TableView is a simple, stateless widget that just displays data
class _TableView extends StatelessWidget {
  final List<Order> orders;
  const _TableView({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Cart')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(Text(order.id.toString(),
                    style: TextStyle(color: Theme.of(context).primaryColor))),
                DataCell(Text('Cart ${order.cartId}')),
                const DataCell(Text('\$0.00')), // TODO: compute from cart_items
                DataCell(OrderStatusBadge.fromString(order.status)),
                DataCell(
                  Row(
                    children: [
                      // The "View" button now calls our helper function
                      TextButton(
                          onPressed: () => _showOrderDetails(context, order),
                          child: const Text('View')),
                      TextButton(onPressed: () {}, child: const Text('Update')),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// The KanbanView is also a simple widget now
class _KanbanView extends StatelessWidget {
  final List<Order> orders;
  const _KanbanView({required this.orders});

  @override
  Widget build(BuildContext context) {
    final pendingOrders =
        orders.where((o) => o.status == 'Pending').toList();
    final preparingOrders =
        orders.where((o) => o.status == 'Preparing').toList();
    final completedOrders =
        orders.where((o) => o.status == 'Done').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Vertical layout for small screens
          return Column(
            children: [
              _KanbanColumn(
                  title: 'New',
                  count: pendingOrders.length,
                  color: Colors.orange,
                  orders: pendingOrders),
              const SizedBox(height: 16),
              _KanbanColumn(
                  title: 'Preparing',
                  count: preparingOrders.length,
                  color: Colors.blue,
                  orders: preparingOrders),
              const SizedBox(height: 16),
              _KanbanColumn(
                  title: 'Ready',
                  count: completedOrders.length,
                  color: Colors.green,
                  orders: completedOrders),
            ],
          );
        } else {
          // Horizontal layout for larger screens
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _KanbanColumn(
                      title: 'New',
                      count: pendingOrders.length,
                      color: Colors.orange,
                      orders: pendingOrders)),
              const SizedBox(width: 16),
              Expanded(
                  child: _KanbanColumn(
                      title: 'Preparing',
                      count: preparingOrders.length,
                      color: Colors.blue,
                      orders: preparingOrders)),
              const SizedBox(width: 16),
              Expanded(
                  child: _KanbanColumn(
                      title: 'Ready',
                      count: completedOrders.length,
                      color: Colors.green,
                      orders: completedOrders)),
            ],
          );
        }
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<Order> orders;

  const _KanbanColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title ($count)',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // We wrap the card in an InkWell to make it tappable
              return InkWell(
                onTap: () => _showOrderDetails(context, order),
                borderRadius: BorderRadius.circular(8.0),
                child: _KanbanCard(order: order),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ],
      ),
    );
  }
}

// === vvv THIS IS THE UPDATED WIDGET vvv ===

// The _KanbanCard widget now shows dynamic items
class _KanbanCard extends StatelessWidget {
  final Order order;
  const _KanbanCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Pickup',
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cart ${order.cartId}', style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),
            // Placeholder until cart items are fetched by cartId
            Text('Items for cart ${order.cartId}',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color)),
          ],
        ),
      ),
    );
  }
}
