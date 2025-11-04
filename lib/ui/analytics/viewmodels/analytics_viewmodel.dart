import 'dart:async';
import 'package:adminshahrayar/data/repositories/analytic_repository.dart';
import 'package:adminshahrayar/data/repositories/customer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adminshahrayar/data/models/analytics_state.dart';
import 'package:adminshahrayar/data/models/cart.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml if not already present

final analyticsViewmodelProvider =
    AsyncNotifierProvider<AnalyticsViewmodel, AnalyticsState>(
        AnalyticsViewmodel.new);

class AnalyticsViewmodel extends AsyncNotifier<AnalyticsState> {
  late final AnalyticsRepository repository;
  late final CustomerRepository customerRepository;
  // Cache carts so we can recompute windows quickly without re-fetching
  List<Cart> _cachedCarts = const [];
  int _dayOffset = 0; // 0 => window ends today, +N => ends N days in future, -N => past

  @override
  FutureOr<AnalyticsState> build() async {
    repository = ref.read(analyticsRepositoryProvider);
    customerRepository = ref.read(customerRepositoryProvider);

    // Fetch all carts (each cart is an order)
    final List<Cart> carts = await repository.getAllCarts();
    _cachedCarts = carts;

    // ✅ Total revenue
    final totalRevenue =
        carts.fold<double>(0.0, (sum, cart) => sum + cart.totalPrice);

    // ✅ Total orders (each cart = one order)
    final totalOrders = carts.length;

    // ✅ Average order value
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    // ✅ Total unique customers (distinct userIds)
    final customerNumber = await customerRepository
        .getAllCustomers()
        .then((customers) => customers.length);

    // Build the initial 30-day window ending today
    final monthlyRevenueData = _buildWindowData(_cachedCarts, _dayOffset);

    return AnalyticsState(
      totalRevenue: totalRevenue,
      totalOrders: totalOrders,
      avgOrderValue: avgOrderValue,
      customerNumber: customerNumber,
      monthlyRevenueData: monthlyRevenueData,
    );
  }

  // Helper to get date key in format "MM/dd"
  String _getDateKey(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }

  // Helper to return last 30 days in order for a window ending at (today + offset)
  List<String> _getLast30Days(int dayOffset) {
    final end = DateTime.now().add(Duration(days: dayOffset));
    return List.generate(30, (i) {
      final day = end.subtract(Duration(days: 29 - i));
      return DateFormat('MM/dd').format(day);
    });
  }

  // Build revenue data for a 30-day window using cached carts and provided offset
  List<Map<String, dynamic>> _buildWindowData(List<Cart> carts, int dayOffset) {
    final Map<String, double> revenueByDay = {};
    final days = _getLast30Days(dayOffset);
    for (final day in days) {
      revenueByDay[day] = 0.0;
    }

    // Window start and end for fast inclusion test
    final windowEnd = DateTime.now().add(Duration(days: dayOffset));
    final windowStart = windowEnd.subtract(const Duration(days: 29));

    for (final cart in carts) {
      if (cart.createdAt.isBefore(windowStart) || cart.createdAt.isAfter(windowEnd)) {
        continue;
      }
      final dayKey = _getDateKey(cart.createdAt);
      if (revenueByDay.containsKey(dayKey)) {
        revenueByDay[dayKey] = (revenueByDay[dayKey] ?? 0) + cart.totalPrice;
      }
    }

    return days
        .map((day) => {
              'day': day,
              'revenue': revenueByDay[day] ?? 0.0,
            })
        .toList();
  }

  // Public: update the offset and recompute the window
  Future<void> setDayOffset(int dayOffset) async {
    _dayOffset = dayOffset;
    final carts = _cachedCarts.isEmpty ? await repository.getAllCarts() : _cachedCarts;
    _cachedCarts = carts;

    // Recompute aggregates
    final totalRevenue = carts.fold<double>(0.0, (sum, cart) => sum + cart.totalPrice);
    final totalOrders = carts.length;
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
    final customerNumber = await customerRepository
        .getAllCustomers()
        .then((customers) => customers.length);

    final monthlyRevenueData = _buildWindowData(carts, _dayOffset);

    state = AsyncData(
      AnalyticsState(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        avgOrderValue: avgOrderValue,
        customerNumber: customerNumber,
        monthlyRevenueData: monthlyRevenueData,
      ),
    );
  }

  // (Removed sparse labels helper; not used)
}