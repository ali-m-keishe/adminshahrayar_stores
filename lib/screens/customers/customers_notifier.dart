import 'package:adminshahrayar/models/customer_review.dart';
import 'package:adminshahrayar/repositories/customer_repository.dart';
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

class CustomersNotifier extends AsyncNotifier<CustomersState> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final ReviewRepository _reviewRepository = ReviewRepository();

  @override
  Future<CustomersState> build() async {
    try {
      final topCustomers = await _customerRepository.getTopCustomers();
      final recentReviews = await _reviewRepository.getRecentReviews();
      return CustomersState(recentReviews: recentReviews, topCustomers: topCustomers);
    } catch (_) {
      return CustomersState(recentReviews: mockRecentReviews, topCustomers: mockTopCustomers);
    }
  }

  Future<void> refreshData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await build());
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await _customerRepository.addCustomer(customer);
      await refreshData(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addReview(Review review) async {
    try {
      await _reviewRepository.addReview(review);
      await refreshData(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }
}

final customersProvider = AsyncNotifierProvider<CustomersNotifier, CustomersState>(() {
  return CustomersNotifier();
});
