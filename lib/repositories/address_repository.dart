import '../models/address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all addresses for a specific user
  Future<List<Address>> getAddressesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('address')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  // Get address by ID
  Future<Address?> getAddressById(int id) async {
    try {
      final response = await _supabase
          .from('address')
          .select()
          .eq('id', id)
          .single();

      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Add new address
  Future<Address> addAddress({
    required String customLabel,
    required String blockNumber,
    required String entrance,
    required String floor,
    required String apartment,
    required double latitude,
    required double longitude,
    required String formattedAddress,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('address')
          .insert({
            'custom_label': customLabel,
            'block_number': blockNumber,
            'entrance': entrance,
            'floor': floor,
            'apartment': apartment,
            'latitude': latitude,
            'longitude': longitude,
            'formatted_address': formattedAddress,
            'user_id': userId,
          })
          .select()
          .single();

      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  // Update address
  Future<Address> updateAddress(Address address) async {
    try {
      final response = await _supabase
          .from('address')
          .update(address.toJson())
          .eq('id', address.id)
          .select()
          .single();

      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(int id) async {
    try {
      await _supabase
          .from('address')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // Search addresses by formatted address
  Future<List<Address>> searchAddresses(String query, String userId) async {
    try {
      final response = await _supabase
          .from('address')
          .select()
          .eq('user_id', userId)
          .ilike('formatted_address', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search addresses: $e');
    }
  }
}
