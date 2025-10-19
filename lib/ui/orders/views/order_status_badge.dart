import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String
      status; // uses Supabase string: 'pending' | 'on the way' | 'done'
  const OrderStatusBadge.fromString(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    late Color color;
    late String text;
    if (normalized == 'pending') {
      color = Colors.orange;
      text = 'Pending';
    } else if (normalized == 'on the way') {
      color = Colors.blue;
      text = 'On the way';
    } else {
      // done
      color = Colors.green;
      text = 'Done';
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
