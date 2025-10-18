import 'package:adminshahrayar/models/order.dart';
import 'package:adminshahrayar/models/order_details.dart';
import 'package:adminshahrayar/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

// Provider for order details
final orderDetailsProvider = FutureProvider.family<OrderDetails?, int>((ref, orderId) async {
  final repository = OrderRepository();
  return await repository.getOrderDetails(orderId);
});

class OrderDetailsDialog extends ConsumerWidget {
  final Order order;
  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderDetailsAsync = ref.watch(orderDetailsProvider(order.id));
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text('Order Details: #${order.id}'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: orderDetailsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Failed to load order details: $error'),
                const SizedBox(height: 8),
                Text('Stack trace: $stack', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(orderDetailsProvider(order.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (orderDetails) {
            if (orderDetails == null) {
              return const Center(
                child: Text('Order details not found'),
              );
            }
            return _buildOrderDetailsContent(context, orderDetails, textTheme);
          },
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

  Widget _buildOrderDetailsContent(BuildContext context, OrderDetails orderDetails, TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Information',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Order ID:', '#${orderDetails.order.id}', textTheme),
                  _buildDetailRow('Cart ID:', orderDetails.order.cartId.toString(), textTheme),
                  _buildDetailRow('Status:', orderDetails.order.status, textTheme),
                  _buildDetailRow('Created:', timeago.format(orderDetails.order.createdAt), textTheme),
                  _buildDetailRow('Payment Token:', orderDetails.order.paymentToken, textTheme),
                  _buildDetailRow('Address ID:', orderDetails.order.addressId.toString(), textTheme),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cart Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cart Information',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Cart Status:', orderDetails.cart.status, textTheme),
                  _buildDetailRow('User ID:', orderDetails.cart.userId, textTheme),
                  _buildDetailRow('Total Price:', '\$${orderDetails.totalPrice.toStringAsFixed(2)}', textTheme),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Items Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items (${orderDetails.items.length})',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...orderDetails.items.map((item) => _buildItemCard(context, item, textTheme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Item Card with Size + Addons
  Widget _buildItemCard(BuildContext context, OrderItemDetails item, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 Item Name and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.displayName,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '\$${item.itemTotalPrice.toStringAsFixed(2)}',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 🔸 Quantity
            Text('Qty: ${item.cartItem.quantity}', style: textTheme.bodyMedium),

            // 🔸 Size (if available)
            if (item.size != null) ...[
              const SizedBox(height: 4),
              Text(
                'Size: ${item.size!.sizeName}',
                style: textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ],

            // 🔸 Addons (if available)
            if (item.addons.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Addons: ${item.addons.map((a) => a.name).join(', ')}',
                style: textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ],

            // 🔸 Note
            if (item.cartItem.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Note: ${item.cartItem.note}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // 🔸 Offer badge
            if (item.cartItem.hasOffer) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'OFFER APPLIED',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
