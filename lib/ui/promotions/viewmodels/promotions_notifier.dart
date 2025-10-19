import 'package:adminshahrayar/data/models/promotion.dart';
import 'package:adminshahrayar/data/repositories/promotion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // We'll use a package to generate unique IDs

class PromotionsNotifier extends StateNotifier<List<Promotion>> {
  final PromotionRepository _promotionRepository = PromotionRepository();

  PromotionsNotifier() : super([]) {
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    try {
      final promotions = await _promotionRepository.getAllPromotions();
      state = promotions;
    } catch (e) {
      // Fallback to mock data if repository fails
      state = mockPromotions;
    }
  }

  Future<void> refreshPromotions() async {
    await _fetchPromotions();
  }

  Future<void> addPromotion(Promotion promo) async {
    try {
      await _promotionRepository.addPromotion(promo);
      await _fetchPromotions(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updatePromotion(Promotion updatedPromo) async {
    try {
      await _promotionRepository.updatePromotion(updatedPromo);
      await _fetchPromotions(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> togglePromotionStatus(String id, bool value) async {
    try {
      await _promotionRepository.togglePromotionStatus(id);
      await _fetchPromotions(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await _promotionRepository.deletePromotion(id);
      await _fetchPromotions(); // Refresh the data
    } catch (e) {
      // Handle error
    }
  }
}

final promotionsProvider =
    StateNotifierProvider<PromotionsNotifier, List<Promotion>>((ref) {
  return PromotionsNotifier();
});

// We can reuse the same uuidProvider from the staff notifier
final uuidProvider = Provider((ref) => const Uuid());
