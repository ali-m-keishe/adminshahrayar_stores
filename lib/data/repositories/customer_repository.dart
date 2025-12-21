import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all customers

  Future<List<Customer>> getAllCustomers() async {
    final response = await _supabase.rpc('get_all_users_basic');

    return (response as List)
        .map((user) =>
            Customer.fromAuthUser(user as Map<String, dynamic>))
        .toList();
  }

  // Get customer by ID
//   Future<Customer?> getCustomerById(String id) async {
//     try {
//       final response =
//           await _supabase.from('customers').select().eq('id', id).single();

//       return Customer.fromJson(Map<String, dynamic>.from(response));
//     } catch (e) {
//       // Fallback to mock data if Supabase fails
//       await Future.delayed(const Duration(milliseconds: 300));
//       try {
//         return mockTopCustomers.firstWhere((customer) => customer.id == id);
//       } catch (e) {
//         return null;
//       }
//     }
//   }

//   // Get top customers by spending
//   Future<List<Customer>> getTopCustomers({int limit = 10}) async {
//     try {
//       final response = await _supabase
//           .from('customers')
//           .select()
//           .order('total_spent', ascending: false)
//           .limit(limit);

//       return (response as List)
//           .map((item) => Customer.fromJson(item as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       // Fallback to mock data if Supabase fails
//       await Future.delayed(const Duration(milliseconds: 400));
//       final sortedCustomers = List<Customer>.from(mockTopCustomers);
//       sortedCustomers.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
//       return sortedCustomers.take(limit).toList();
//     }
//   }

//   // Search customers by name
//   Future<List<Customer>> searchCustomers(String query) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return mockTopCustomers
//         .where((customer) =>
//             customer.name.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//   }

//   // Add new customer
//   Future<Customer> addCustomer(Customer customer) async {
//     try {
//       final response = await _supabase
//           .from('customers')
//           .insert(customer.toJson())
//           .select()
//           .single();

//       return Customer.fromJson(Map<String, dynamic>.from(response));
//     } catch (e) {
//       // Fallback behavior if Supabase fails
//       await Future.delayed(const Duration(milliseconds: 800));
//       throw Exception('Failed to add customer: $e');
//     }
//   }

//   // Update customer
//   Future<Customer> updateCustomer(Customer customer) async {
//     await Future.delayed(const Duration(milliseconds: 600));
//     // In a real app, this would make an API call to update the customer
//     return customer;
//   }

//   // Delete customer
//   Future<void> deleteCustomer(String id) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     // In a real app, this would make an API call to delete the customer
//   }
// }
}
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});
