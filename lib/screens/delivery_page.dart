import 'package:adminshahrayar/models/driver.dart';
import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/screens/driver/drivers_notifier.dart';
import 'package:adminshahrayar/screens/orders/orders_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryPage extends ConsumerWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both providers to get the data we need
    final allOrders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];
    final drivers = ref.watch(driversProvider);

    // Filter the orders to find the ones ready for delivery but unassigned
    final unassignedOrders = allOrders
        .where((o) => o.status.toLowerCase() == 'done')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Management',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Area
                  Expanded(
                    flex: isWide ? 2 : 0,
                    child: SizedBox(
                      height: isWide ? 600 : 300,
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined,
                                  size: 60, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text('Live Map Placeholder',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isWide)
                    const SizedBox(width: 24)
                  else
                    const SizedBox(height: 24),
                  // Lists Area
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _UnassignedOrdersCard(orders: unassignedOrders),
                        const SizedBox(height: 24),
                        _DriversCard(drivers: drivers.valueOrNull ?? []),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UnassignedOrdersCard extends StatelessWidget {
  final List<Order> orders;
  const _UnassignedOrdersCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unassigned Orders (${orders.length})',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Constrain the height of the list
              child: orders.isEmpty
                  ? const Center(child: Text('No orders ready for delivery.'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return ListTile(
                          title: Text(order.id.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Cart ${order.cartId}'),
                          trailing: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Assign'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriversCard extends StatelessWidget {
  final List<Driver> drivers;
  const _DriversCard({required this.drivers});

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.Available:
        return Colors.green;
      case DriverStatus.OnDelivery:
        return Colors.orange;
      case DriverStatus.Offline:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Drivers (${drivers.length})',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundColor: _getStatusColor(driver.status),
                        radius: 8),
                    title: Text(driver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(driver.status.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
