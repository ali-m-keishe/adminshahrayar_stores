import 'package:adminshahrayar_stores/data/models/promotion.dart';
import 'package:adminshahrayar_stores/data/repositories/promotion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PromotionsNotifier extends AsyncNotifier<List<Promotion>> {
  @override
  Future<List<Promotion>> build() async {
    // This fetches the initial list of promotions when the page loads.
    return ref.watch(promotionRepositoryProvider).getAllPromotions();
  }

  Future<void> savePromotion(
      {int? id, required Map<String, dynamic> data}) async {
    final repo = ref.read(promotionRepositoryProvider);
    state = const AsyncLoading(); // Set UI to loading

    // Use AsyncValue.guard to safely handle errors from the database call
    state = await AsyncValue.guard(() async {
      await repo.savePromotion(id: id, data: data);
      // After saving, re-fetch the entire list to show the changes
      return repo.getAllPromotions();
    });
  }

  // Method to toggle the active status of a promotion
  Future<void> togglePromotionStatus(int id, bool newStatus) async {
    final repo = ref.read(promotionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.togglePromotionStatus(id, newStatus);
      return repo.getAllPromotions(); // Refresh list
    });
  }

  Future<void> deletePromotion(int id) async {
    final repo = ref.read(promotionRepositoryProvider);
    state = const AsyncLoading(); // Show loading spinner

    // Use guard to handle errors and refresh the list automatically
    state = await AsyncValue.guard(() async {
      await repo.deletePromotion(id);
      return repo.getAllPromotions(); // Re-fetch the list to show the deletion
    });
  }
}

// The provider for our AsyncNotifier
final promotionsProvider =
    AsyncNotifierProvider<PromotionsNotifier, List<Promotion>>(() {
  return PromotionsNotifier();
});
