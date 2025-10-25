import 'package:adminshahrayar/data/models/promotion.dart';
import 'package:adminshahrayar/data/repositories/promotion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The AsyncNotifier directly manages the state (e.g., AsyncValue<List<Promotion>>)
// so we don't need a separate PromotionState class.
class PromotionsNotifier extends AsyncNotifier<List<Promotion>> {
  // The build method is called automatically to fetch the initial data.
  @override
  Future<List<Promotion>> build() async {
    // It reads the repository from its provider and fetches the data.
    return ref.watch(promotionRepositoryProvider).getAllPromotions();
  }

  Future<void> addPromotion(Map<String, dynamic> promoData) async {
    final repo = ref.read(promotionRepositoryProvider);
    // Set UI to loading state while we perform the action
    state = const AsyncLoading();
    // Use AsyncValue.guard to handle potential errors
    state = await AsyncValue.guard(() async {
      await repo.addPromotion(promoData);
      // Re-fetch the list to show the new promotion
      return repo.getAllPromotions();
    });
  }

  Future<void> updatePromotion(int id, Map<String, dynamic> promoData) async {
    final repo = ref.read(promotionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updatePromotion(id, promoData);
      return repo.getAllPromotions();
    });
  }

  Future<void> togglePromotionStatus(int id, bool newStatus) async {
    final repo = ref.read(promotionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.togglePromotionStatus(id, newStatus);
      return repo.getAllPromotions();
    });
  }
}

// The provider for our AsyncNotifier
final promotionsProvider =
    AsyncNotifierProvider<PromotionsNotifier, List<Promotion>>(() {
  return PromotionsNotifier();
});
