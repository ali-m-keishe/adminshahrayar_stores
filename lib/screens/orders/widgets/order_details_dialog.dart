import 'package:adminshahrayar/models/order.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago; // 1. ADD THIS IMPORT

class OrderDetailsDialog extends StatelessWidget {
  final Order order;
  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text('Order Details: ${order.id}'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer:', order.customer, textTheme),
              // 2. THIS IS THE FIX for the 'time' error
              _buildDetailRow(
                  'Time:', timeago.format(order.createdAt), textTheme),
              _buildDetailRow(
                  'Total:', '\$${order.total.toStringAsFixed(2)}', textTheme),
              _buildDetailRow('Status:', order.status.name, textTheme),
              const Divider(height: 30),
              Text('Items',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items.map((item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.fastfood_outlined),
                    title: Text('${item.quantity} x ${item.itemName}'),
                    subtitle: item.modifiers.isNotEmpty
                        ? Text('Mods: ${item.modifiers.join(', ')}')
                        : null,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.print_outlined, size: 18),
          label: const Text('Print Receipt'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
