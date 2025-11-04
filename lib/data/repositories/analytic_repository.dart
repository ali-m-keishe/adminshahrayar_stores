import 'package:adminshahrayar/data/models/cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch all carts that have resulted in orders
  Future<List<Cart>> getAllCarts() async {
    try {
      // Fetch carts with their associated orders
      // Using inner join to only get carts that have orders
      final response = await supabase
          .from('cart')
          .select('''
            cart_id,
            created_at,
            status,
            user_id,
            total_price,
            orders!inner(
              id,
              created_at,
              status,
              payment_token,
              address_id
            )
          ''')
          .eq('status', 'ordered')
          .order('created_at', ascending: false);

      print('📊 Repository: Fetched ${response.length} carts with orders');

      final carts = (response as List<dynamic>)
          .map((data) => Cart.fromJson(data as Map<String, dynamic>))
          .toList();

      // Log some debug info
      for (final cart in carts.take(5)) {
        print('Cart ${cart.cartId}: \$${cart.totalPrice} on ${cart.createdAt}');
      }

      return carts;
    } catch (e, stack) {
      print('❌ Error fetching carts: $e');
      print(stack);
      return [];
    }
  }

  /// Alternative method: Fetch carts within a specific date range
  Future<List<Cart>> getCartsInDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final response = await supabase
          .from('cart')
          .select('''
            cart_id,
            created_at,
            status,
            user_id,
            total_price,
            orders!inner(
              id,
              created_at,
              status,
              payment_token,
              address_id
            )
          ''')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .eq('status', 'ordered')
          .order('created_at', ascending: false);

      final carts = (response as List<dynamic>)
          .map((data) => Cart.fromJson(data as Map<String, dynamic>))
          .toList();

      print('📊 Date Range: Found ${carts.length} carts between ${startDate.toString().split(' ')[0]} and ${endDate.toString().split(' ')[0]}');
      
      return carts;
    } catch (e) {
      print('❌ Error fetching carts in date range: $e');
      return [];
    }
  }

  /// Get daily revenue for the last N days
  Future<Map<String, double>> getDailyRevenue(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      // Fetch carts in the date range
      final carts = await getCartsInDateRange(startDate, endDate);
      
      // Group by date
      final Map<String, double> dailyRevenue = {};
      
      for (final cart in carts) {
        final dateKey = '${cart.createdAt.year}-${cart.createdAt.month.toString().padLeft(2, '0')}-${cart.createdAt.day.toString().padLeft(2, '0')}';
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + cart.totalPrice;
      }
      
      return dailyRevenue;
    } catch (e) {
      print('❌ Error getting daily revenue: $e');
      return {};
    }
  }

  /// Get revenue statistics
  Future<Map<String, dynamic>> getRevenueStatistics() async {
    try {
      final carts = await getAllCarts();
      
      if (carts.isEmpty) {
        return {
          'totalRevenue': 0.0,
          'totalOrders': 0,
          'averageOrderValue': 0.0,
          'maxOrderValue': 0.0,
          'minOrderValue': 0.0,
        };
      }
      
      final totalRevenue = carts.fold<double>(
        0.0, 
        (sum, cart) => sum + cart.totalPrice
      );
      
      final prices = carts.map((c) => c.totalPrice).toList();
      prices.sort();
      
      return {
        'totalRevenue': totalRevenue,
        'totalOrders': carts.length,
        'averageOrderValue': totalRevenue / carts.length,
        'maxOrderValue': prices.last,
        'minOrderValue': prices.first,
      };
    } catch (e) {
      print('❌ Error getting revenue statistics: $e');
      return {
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'averageOrderValue': 0.0,
        'maxOrderValue': 0.0,
        'minOrderValue': 0.0,
      };
    }
  }
}

/// ✅ Provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});