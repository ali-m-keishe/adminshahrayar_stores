import 'package:adminshahrayar/models/order.dart';
import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.Pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case OrderStatus.Preparing:
        color = Colors.blue;
        text = 'Preparing';
        break;
      case OrderStatus.Completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case OrderStatus.Cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
