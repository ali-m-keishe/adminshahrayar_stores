import 'package:adminshahrayar/data/models/cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AnalyticsRepository {
  final supabase = Supabase.instance.client;

  /// 🧮 إرجاع إجمالي الإيرادات
 Future<List<Cart>> getAllCarts() async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('cart')
      .select('*')   // Select all columns
      .order('cart_id', ascending: true);

  // Convert to List<Cart>
  final carts = (response as List<dynamic>)
      .map((data) => Cart.fromJson(data as Map<String, dynamic>))
      .toList();

  return carts;
}
}

/// ✅ Provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

