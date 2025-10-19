import 'package:adminshahrayar/data/models/order.dart';
import 'package:adminshahrayar/ui/orders/viewmodels/orders_notifier.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Define the different filter options
enum DateFilter { All, Today, LastWeek, LastMonth, LastYear }

// 2. Create a simple notifier to hold the currently selected filter
class AllOrdersFilterNotifier extends StateNotifier<DateFilter> {
  AllOrdersFilterNotifier() : super(DateFilter.All);

  void setFilter(DateFilter filter) {
    state = filter;
  }
}

// 3. Create a provider for our new notifier
final allOrdersFilterProvider =
    StateNotifierProvider<AllOrdersFilterNotifier, DateFilter>((ref) {
  return AllOrdersFilterNotifier();
});

// 4. Create the final "filtered" provider
// This provider cleverly watches BOTH the main orders list and the filter provider.
// If either one changes, it will re-run its logic and provide a new, filtered list to the UI.
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final filter = ref.watch(allOrdersFilterProvider);
  final orders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];
  final now = DateTime.now();

  switch (filter) {
    case DateFilter.Today:
      return orders
          .where((order) =>
              order.createdAt.year == now.year &&
              order.createdAt.month == now.month &&
              order.createdAt.day == now.day)
          .toList();
    case DateFilter.LastWeek:
      return orders
          .where((order) =>
              order.createdAt.isAfter(now.subtract(const Duration(days: 7))))
          .toList();
    case DateFilter.LastMonth:
      return orders
          .where((order) =>
              order.createdAt.isAfter(now.subtract(const Duration(days: 30))))
          .toList();
    case DateFilter.LastYear:
      return orders
          .where((order) =>
              order.createdAt.isAfter(now.subtract(const Duration(days: 365))))
          .toList();
    case DateFilter.All:
      return orders;
  }
});

// 5. Create a provider for filtering orders by status (pending and on the way)
final pendingAndOnTheWayOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersProvider).valueOrNull?.orders ?? [];

  return orders
      .where((order) =>
          order.status.toLowerCase() == 'pending' ||
          order.status.toLowerCase() == 'on the way')
      .toList();
});
