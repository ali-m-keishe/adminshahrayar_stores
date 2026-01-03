import 'package:adminshahrayar_stores/data/models/order.dart';
import 'package:adminshahrayar_stores/data/models/order_details.dart';
import 'package:adminshahrayar_stores/data/repositories/order_repository.dart';
import 'package:adminshahrayar_stores/ui/orders/views/address_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

// Provider for order details
final orderDetailsProvider =
    FutureProvider.family<OrderDetails?, int>((ref, orderId) async {
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
                Text('Stack trace: $stack',
                    style: const TextStyle(fontSize: 12)),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Order details not found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order ID: #${order.id}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () => ref.refresh(orderDetailsProvider(order.id)),
                    ),
                  ],
                ),
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

  Widget _buildOrderDetailsContent(
      BuildContext context, OrderDetails orderDetails, TextTheme textTheme) {
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
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      'Order ID:', '#${orderDetails.order.id}', textTheme),
                  _buildDetailRow('Cart ID:',
                      orderDetails.order.cartId.toString(), textTheme),
                  _buildDetailRow(
                      'Status:', orderDetails.order.status, textTheme),
                  _buildDetailRow('Created:',
                      timeago.format(orderDetails.order.createdAt), textTheme),
                  _buildDetailRow('Payment Token:',
                      orderDetails.order.paymentToken, textTheme),
                  _buildClickableAddressRow(
                      context,
                      'Address:',
                      orderDetails.order.addressId,
                      orderDetails.order.addressFormatted,
                      textTheme),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Customer Information - Prominent Section
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Customer Details',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Debug: Print customer info
                  Builder(
                    builder: (context) {
                      print('🔍 [DIALOG] Customer info - email: ${orderDetails.email}, phone: ${orderDetails.phone}');
                      print('🔍 [DIALOG] Cart email: ${orderDetails.cart.email}, phone: ${orderDetails.cart.phone}');
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Always show email if available
                  if (orderDetails.email != null && orderDetails.email!.isNotEmpty)
                    _buildCustomerDetailRow(
                      context,
                      Icons.email,
                      'Email:',
                      orderDetails.email!,
                      textTheme,
                    )
                  else if (orderDetails.cart.email != null && orderDetails.cart.email!.isNotEmpty)
                    _buildCustomerDetailRow(
                      context,
                      Icons.email,
                      'Email:',
                      orderDetails.cart.email!,
                      textTheme,
                    ),
                  
                  // Always show phone if available
                  if (orderDetails.phone != null && orderDetails.phone!.isNotEmpty)
                    _buildCustomerDetailRow(
                      context,
                      Icons.phone,
                      'Phone:',
                      orderDetails.phone!,
                      textTheme,
                    )
                  else if (orderDetails.cart.phone != null && orderDetails.cart.phone!.isNotEmpty)
                    _buildCustomerDetailRow(
                      context,
                      Icons.phone,
                      'Phone:',
                      orderDetails.cart.phone!,
                      textTheme,
                    ),
                  
                  // Show message if no contact info available
                  if ((orderDetails.email == null || orderDetails.email!.isEmpty) &&
                      (orderDetails.phone == null || orderDetails.phone!.isEmpty) &&
                      (orderDetails.cart.email == null || orderDetails.cart.email!.isEmpty) &&
                      (orderDetails.cart.phone == null || orderDetails.cart.phone!.isEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, 
                            color: Colors.orange[300], 
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No contact information available',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.orange[300],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Show User ID as fallback
                  if ((orderDetails.email == null || orderDetails.email!.isEmpty) &&
                      (orderDetails.phone == null || orderDetails.phone!.isEmpty) &&
                      (orderDetails.cart.email == null || orderDetails.cart.email!.isEmpty) &&
                      (orderDetails.cart.phone == null || orderDetails.cart.phone!.isEmpty))
                    _buildDetailRow(
                      'User ID:',
                      orderDetails.cart.userId,
                      textTheme,
                    ),
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
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      'Cart Status:', orderDetails.cart.status, textTheme),
                  _buildDetailRow(
                      'Total Price:',
                      '\$${orderDetails.totalPrice.toStringAsFixed(2)}',
                      textTheme),
                  _buildDetailRow(
                      'Shipping Fee:',
                      '\$${orderDetails.shippingFee.toStringAsFixed(2)}',
                      textTheme),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  _buildDetailRow(
                    'Sub Total:',
                    '\$${orderDetails.subTotal.toStringAsFixed(2)}',
                    textTheme, 
                  ),
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
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...orderDetails.items
                      .map((item) => _buildItemCard(context, item, textTheme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Item Card with Size + Addons
  Widget _buildItemCard(
      BuildContext context, OrderItemDetails item, TextTheme textTheme) {
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
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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

            // 🔸 ArcNo (optional)
            const SizedBox(height: 4),
            Text(
              'ArcNo: ${item.menuItem.arcNo != null && item.menuItem.arcNo!.isNotEmpty ? item.menuItem.arcNo! : '--'}',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),

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

  Widget _buildDetailRow(String title, String value, TextTheme textTheme,
      {TextStyle? valueStyle}) {
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
              style: valueStyle ?? textTheme.bodyLarge,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableAddressRow(
    BuildContext context,
    String title,
    int? addressId,
    String? addressFormatted,
    TextTheme textTheme,
  ) {
    final addressText = addressId == null || addressId == 0
        ? 'Address is empty or deleted'
        : (addressFormatted ?? 'Address #$addressId');
    
    final isClickable = addressId != null && addressId != 0;
    
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
            child: isClickable
                ? InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddressDetailsDialog(addressId: addressId),
                      );
                    },
                    child: Text(
                      addressText,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  )
                : Text(
                    addressText,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}
