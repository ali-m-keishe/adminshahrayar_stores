import 'package:adminshahrayar/models/promotion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // We'll use a package to generate unique IDs

class PromotionsNotifier extends StateNotifier<List<Promotion>> {
  PromotionsNotifier() : super([]) {
    _fetchPromotions();
  }

  void _fetchPromotions() {
    state = mockPromotions;
  }

  void addPromotion(Promotion promo) {
    state = [...state, promo];
  }

  void updatePromotion(Promotion updatedPromo) {
    state = [
      for (final promo in state)
        if (promo.id == updatedPromo.id) updatedPromo else promo,
    ];
  }

  void togglePromotionStatus(String id, bool isActive) {
    state = [
      for (final promo in state)
        if (promo.id == id)
          Promotion(
            id: promo.id,
            code: promo.code,
            description: promo.description,
            discountType: promo.discountType,
            discountValue: promo.discountValue,
            isActive: isActive,
          )
        else
          promo,
    ];
  }
}

final promotionsProvider =
    StateNotifierProvider<PromotionsNotifier, List<Promotion>>((ref) {
  return PromotionsNotifier();
});

// We can reuse the same uuidProvider from the staff notifier
final uuidProvider = Provider((ref) => const Uuid());
