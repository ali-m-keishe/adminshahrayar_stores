import 'package:adminshahrayar/models/customer_review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomersState {
  final List<Review> recentReviews;
  final List<Customer> topCustomers;

  CustomersState({
    this.recentReviews = const [],
    this.topCustomers = const [],
  });

  CustomersState copyWith({
    List<Review>? recentReviews,
    List<Customer>? topCustomers,
  }) {
    return CustomersState(
      recentReviews: recentReviews ?? this.recentReviews,
      topCustomers: topCustomers ?? this.topCustomers,
    );
  }
}

class CustomersNotifier extends StateNotifier<CustomersState> {
  CustomersNotifier() : super(CustomersState()) {
    _fetchData();
  }

  void _fetchData() {
    // In a real app, this data would come from an API
    state = state.copyWith(
      recentReviews: mockRecentReviews,
      topCustomers: mockTopCustomers,
    );
  }
}

final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  return CustomersNotifier();
});
