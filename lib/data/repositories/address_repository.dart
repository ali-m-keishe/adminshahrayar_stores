import '../models/address.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all addresses for a user + region name
  Future<List<Address>> getAddressesByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('address')
          .select('*, regions:regions!address_region_id_fkey(name)')

          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  // Get specific address + region name
Future<Address?> getAddressById(int id) async {
  try {
    final response = await _supabase
        .from('address')
        .select('*, regions:regions!address_region_id_fkey(name)')

        .eq('id', id)
        .single();

    return Address.fromJson(Map<String, dynamic>.from(response));
  } catch (e) {
    print('Error fetching address: $e');
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
    required int regionId,
  }) async {
    try {
      final response = await _supabase
          .from('address')
          .insert({
            'custom_label': customLabel,
            'latitude': latitude,
            'longitude': longitude,
            'formatted_address': formattedAddress,
            'user_id': userId,
            'region_id': regionId, // This stays in DB only
          })
          .select('*, regions:regions!address_region_id_fkey(name)')

          .single();

      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  // Update existing address
  Future<Address> updateAddress(int id, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _supabase
          .from('address')
          .update(data)
          .eq('id', id)
          .select('*, regions:regions!address_region_id_fkey(name)')

          .single();

      return Address.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  // Delete address
  Future<void> deleteAddress(int id) async {
    try {
      await _supabase.from('address').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // Search addresses
  Future<List<Address>> searchAddresses(String query, String userId) async {
    try {
      final response = await _supabase
          .from('address')
          .select('*, regions:regions!address_region_id_fkey(name)')

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
