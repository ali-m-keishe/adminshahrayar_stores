import 'package:adminshahrayar_stores/data/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget to display user email/phone for an order
/// Fetches user info asynchronously
class UserInfoCell extends ConsumerWidget {
  final String? userId;
  final int? cartId; // Fallback: if userId is null, fetch from cartId
  final bool showEmail;
  final bool showPhone;

  const UserInfoCell({
    super.key,
    this.userId,
    this.cartId,
    this.showEmail = true,
    this.showPhone = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = OrderRepository();
    
    // If userId is not available, try to fetch it from cartId
    Future<Map<String, String?>> fetchUserInfo() async {
      String? effectiveUserId = userId;
      
      if (effectiveUserId == null || effectiveUserId.isEmpty) {
        if (cartId != null) {
          print('🔍 UserInfoCell - userId is null, fetching from cartId: $cartId');
          effectiveUserId = await repository.getUserIdFromCart(cartId!);
        }
      }
      
      if (effectiveUserId == null || effectiveUserId.isEmpty) {
        print('⚠️ UserInfoCell - No userId available');
        return {'email': null, 'phone': null};
      }
      
      print('🔍 UserInfoCell - Fetching info for userId: $effectiveUserId');
      return await repository.getUserInfo(effectiveUserId);
    }
    
    final userInfoFuture = fetchUserInfo();

    return FutureBuilder<Map<String, String?>>(
      future: userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError) {
          print('❌ UserInfoCell - Error: ${snapshot.error}');
          return const Text('-', style: TextStyle(color: Colors.grey));
        }

        final userInfo = snapshot.data ?? {};
        final email = userInfo['email'];
        final phone = userInfo['phone'];
        print('📧 UserInfoCell - email: $email, phone: $phone');

        if (showEmail && showPhone) {
          // Show both email and phone
          final parts = <String>[];
          if (email != null && email.isNotEmpty) parts.add(email);
          if (phone != null && phone.isNotEmpty) parts.add(phone);
          if (parts.isEmpty) {
            return const Text('-', style: TextStyle(color: Colors.grey));
          }
          return Text(
            parts.join('\n'),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        } else if (showEmail) {
          return Text(
            email ?? '-',
            style: TextStyle(color: email == null ? Colors.grey : null),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        } else if (showPhone) {
          return Text(
            phone ?? '-',
            style: TextStyle(color: phone == null ? Colors.grey : null),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return const Text('-', style: TextStyle(color: Colors.grey));
      },
    );
  }
}

