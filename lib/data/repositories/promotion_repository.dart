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
          .select('*, promotion_items(items(*))')
          .order('created_at', ascending: false);
      return (response as List)
          .map((item) => Promotion.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching promotions: $e');
      throw Exception('Failed to load promotions');
    }
  }

  Future<List<Map<String, dynamic>>> getAllPromotionItemLinks() async {
    try {
      final response = await _supabase
          .from('promotion_items')
          .select('item_id, promotion_id');
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching promotion links: $e');
      return [];
    }
  }

  Future<void> savePromotion(
      {int? id, required Map<String, dynamic> data}) async {
    final promoData = {
      'name': data['name'],
      'description': data['description'],
      'discount_type': data['discount_type'],
      'discount_value': data['discount_value'],
      'start_date': (data['start_date'] as DateTime).toIso8601String(),
      'end_date': (data['end_date'] as DateTime).toIso8601String(),
      'is_active': data['is_active'],
    };
    final itemIds = data['item_ids'] as List<int>;

    try {
      // Step 1: Insert or update the promotion to get its ID
      final savedPromo = await _supabase
          .from('promotions')
          .upsert(id == null ? promoData : {'id': id, ...promoData})
          .select()
          .single();

      final promotionId = savedPromo['id'];

      // Step 2: Delete old links for this promotion
      await _supabase
          .from('promotion_items')
          .delete()
          .eq('promotion_id', promotionId);

      // Step 3: Insert new links if any items were selected
      if (itemIds.isNotEmpty) {
        final links = itemIds
            .map((itemId) => {'promotion_id': promotionId, 'item_id': itemId})
            .toList();
        await _supabase.from('promotion_items').insert(links);
      }
    } catch (e) {
      print('Error saving promotion: $e');
      throw Exception('Failed to save promotion');
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

  Future<void> deletePromotion(int id) async {
    try {
      // First, delete any links in the promotion_items table
      await _supabase.from('promotion_items').delete().eq('promotion_id', id);
      // Then, delete the promotion itself from the promotions table
      await _supabase.from('promotions').delete().eq('id', id);
    } catch (e) {
      print('Error deleting promotion: $e');
      throw Exception('Failed to delete promotion');
    }
  }
}

// A provider for our repository, so the notifier can access it.
final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepository();
});
