import '../models/region.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all regions
  Future<List<Region>> getAllRegions() async {
    try {
      final response = await _supabase
          .from('regions')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Region.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error fetching regions: $e');
      throw Exception('Failed to fetch regions: $e');
    }
  }

  // Get region by ID
  Future<Region?> getRegionById(int id) async {
    try {
      final response = await _supabase
          .from('regions')
          .select()
          .eq('id', id)
          .single();

      return Region.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error fetching region: $e');
      return null;
    }
  }

  // Add new region
  Future<Region> addRegion({
    required String name,
    required int deliveryFee,
  }) async {
    try {
      final response = await _supabase
          .from('regions')
          .insert({
            'name': name,
            'delivery_fee': deliveryFee,
          })
          .select()
          .single();

      return Region.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error adding region: $e');
      throw Exception('Failed to add region: $e');
    }
  }

  // Update region
  Future<Region> updateRegion({
    required int id,
    required String name,
    required int deliveryFee,
  }) async {
    try {
      final response = await _supabase
          .from('regions')
          .update({
            'name': name,
            'delivery_fee': deliveryFee,
          })
          .eq('id', id)
          .select()
          .single();

      return Region.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating region: $e');
      throw Exception('Failed to update region: $e');
    }
  }

  // Delete region
  Future<void> deleteRegion(int id) async {
    try {
      await _supabase.from('regions').delete().eq('id', id);
    } catch (e) {
      print('Error deleting region: $e');
      throw Exception('Failed to delete region: $e');
    }
  }
}

