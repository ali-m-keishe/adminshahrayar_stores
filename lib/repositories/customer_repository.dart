import '../models/customer_review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all customers
  Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('total_spent', ascending: false);

      return (response as List)
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 500));
      return mockTopCustomers;
    }
  }

  // Get customer by ID
  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
          .single();

      return Customer.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return mockTopCustomers.firstWhere((customer) => customer.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get top customers by spending
  Future<List<Customer>> getTopCustomers({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('total_spent', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 400));
      final sortedCustomers = List<Customer>.from(mockTopCustomers);
      sortedCustomers.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
      return sortedCustomers.take(limit).toList();
    }
  }

  // Search customers by name
  Future<List<Customer>> searchCustomers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockTopCustomers
        .where((customer) =>
            customer.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add new customer
  Future<Customer> addCustomer(Customer customer) async {
    try {
      final response = await _supabase
          .from('customers')
          .insert(customer.toJson())
          .select()
          .single();

      return Customer.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback behavior if Supabase fails
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Failed to add customer: $e');
    }
  }

  // Update customer
  Future<Customer> updateCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the customer
    return customer;
  }

  // Delete customer
  Future<void> deleteCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would make an API call to delete the customer
  }
}

class ReviewRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all reviews
  Future<List<Review>> getAllReviews() async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 500));
      return mockRecentReviews;
    }
  }

  // Get recent reviews
  Future<List<Review>> getRecentReviews({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockRecentReviews.take(limit).toList();
  }

  // Get reviews by rating
  Future<List<Review>> getReviewsByRating(int rating) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockRecentReviews
        .where((review) => review.rating == rating)
        .toList();
  }

  // Get reviews with minimum rating
  Future<List<Review>> getReviewsWithMinimumRating(int minRating) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockRecentReviews
        .where((review) => review.rating >= minRating)
        .toList();
  }

  // Add new review
  Future<Review> addReview(Review review) async {
    try {
      final response = await _supabase
          .from('reviews')
          .insert(review.toJson())
          .select()
          .single();

      return Review.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Fallback behavior if Supabase fails
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Failed to add review: $e');
    }
  }

  // Get average rating
  Future<double> getAverageRating() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mockRecentReviews.isEmpty) return 0.0;
    
    final totalRating = mockRecentReviews
        .map((review) => review.rating)
        .reduce((a, b) => a + b);
    return totalRating / mockRecentReviews.length;
  }

  // Get rating distribution
  Future<Map<int, int>> getRatingDistribution() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final distribution = <int, int>{};
    
    for (final review in mockRecentReviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    
    return distribution;
  }
}
