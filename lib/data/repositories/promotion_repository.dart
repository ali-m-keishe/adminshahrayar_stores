import 'package:adminshahrayar/data/models/promotion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all promotions from the database
  Future<List<Promotion>> getAllPromotions() async {
    try {
      final response = await _supabase
          .from('promotions')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Promotion.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching promotions: $e');
      throw Exception('Failed to load promotions');
    }
  }

  Future<void> addPromotion(Map<String, dynamic> promoData) async {
    try {
      await _supabase.from('promotions').insert(promoData);
    } catch (e) {
      print('Error adding promotion: $e');
      throw Exception('Failed to add promotion');
    }
  }

  // Updates an existing promotion in the database
  Future<void> updatePromotion(int id, Map<String, dynamic> promoData) async {
    try {
      await _supabase.from('promotions').update(promoData).eq('id', id);
    } catch (e) {
      print('Error updating promotion: $e');
      throw Exception('Failed to update promotion');
    }
  }

  // A specific, efficient method to toggle the active status
  Future<void> togglePromotionStatus(int id, bool newStatus) async {
    try {
      await _supabase
          .from('promotions')
          .update({'is_active': newStatus}).eq('id', id);
    } catch (e) {
      print('Error toggling promotion status: $e');
      throw Exception('Failed to toggle status');
    }
  }
}

// A provider for our repository, so the notifier can access it.
final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepository();
});
