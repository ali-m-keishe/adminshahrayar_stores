import '../models/promotion.dart';

class PromotionRepository {
  // Get all promotions
  Future<List<Promotion>> getAllPromotions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockPromotions;
  }

  // Get promotion by ID
  Future<Promotion?> getPromotionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockPromotions.firstWhere((promotion) => promotion.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get promotion by code
  Future<Promotion?> getPromotionByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockPromotions.firstWhere((promotion) => promotion.code == code);
    } catch (e) {
      return null;
    }
  }

  // Get active promotions
  Future<List<Promotion>> getActivePromotions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions.where((promotion) => promotion.isActive).toList();
  }

  // Get inactive promotions
  Future<List<Promotion>> getInactivePromotions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions.where((promotion) => !promotion.isActive).toList();
  }

  // Get promotions by discount type
  Future<List<Promotion>> getPromotionsByType(DiscountType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions
        .where((promotion) => promotion.discountType == type)
        .toList();
  }

  // Get percentage promotions
  Future<List<Promotion>> getPercentagePromotions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions
        .where((promotion) => promotion.discountType == DiscountType.Percentage)
        .toList();
  }

  // Get fixed amount promotions
  Future<List<Promotion>> getFixedAmountPromotions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions
        .where(
            (promotion) => promotion.discountType == DiscountType.FixedAmount)
        .toList();
  }

  // Search promotions by code or description
  Future<List<Promotion>> searchPromotions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions
        .where((promotion) =>
            promotion.code.toLowerCase().contains(query.toLowerCase()) ||
            promotion.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get promotions with minimum discount value
  Future<List<Promotion>> getPromotionsWithMinimumDiscount(
      double minValue) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPromotions
        .where((promotion) => promotion.discountValue >= minValue)
        .toList();
  }

  // Add new promotion
  Future<Promotion> addPromotion(Promotion promotion) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would make an API call to add the promotion
    return promotion;
  }

  // Update promotion
  Future<Promotion> updatePromotion(Promotion promotion) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the promotion
    return promotion;
  }

  // Activate promotion
  Future<Promotion> activatePromotion(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final promotion = await getPromotionById(id);
    if (promotion == null) {
      throw Exception('Promotion not found');
    }

    final updatedPromotion = Promotion(
      id: promotion.id,
      code: promotion.code,
      description: promotion.description,
      discountType: promotion.discountType,
      discountValue: promotion.discountValue,
      isActive: true,
    );

    // In a real app, this would make an API call to activate the promotion
    return updatedPromotion;
  }

  // Deactivate promotion
  Future<Promotion> deactivatePromotion(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final promotion = await getPromotionById(id);
    if (promotion == null) {
      throw Exception('Promotion not found');
    }

    final updatedPromotion = Promotion(
      id: promotion.id,
      code: promotion.code,
      description: promotion.description,
      discountType: promotion.discountType,
      discountValue: promotion.discountValue,
      isActive: false,
    );

    // In a real app, this would make an API call to deactivate the promotion
    return updatedPromotion;
  }

  // Delete promotion
  Future<void> deletePromotion(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would make an API call to delete the promotion
  }

  // Validate promotion code
  Future<bool> validatePromotionCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final promotion = await getPromotionByCode(code);
    return promotion != null && promotion.isActive;
  }

  // Get promotion statistics
  Future<Map<String, dynamic>> getPromotionStatistics() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final totalPromotions = mockPromotions.length;
    final activePromotions = mockPromotions.where((p) => p.isActive).length;
    final inactivePromotions = totalPromotions - activePromotions;

    final percentagePromotions = mockPromotions
        .where((p) => p.discountType == DiscountType.Percentage)
        .length;
    final fixedAmountPromotions = totalPromotions - percentagePromotions;

    final averageDiscountValue =
        mockPromotions.map((p) => p.discountValue).reduce((a, b) => a + b) /
            totalPromotions;

    return {
      'totalPromotions': totalPromotions,
      'activePromotions': activePromotions,
      'inactivePromotions': inactivePromotions,
      'percentagePromotions': percentagePromotions,
      'fixedAmountPromotions': fixedAmountPromotions,
      'averageDiscountValue': averageDiscountValue,
    };
  }

  // Get best value promotions (highest discount value)
  Future<List<Promotion>> getBestValuePromotions({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sortedPromotions = List<Promotion>.from(mockPromotions);
    sortedPromotions.sort((a, b) => b.discountValue.compareTo(a.discountValue));
    return sortedPromotions.take(limit).toList();
  }

  // Toggle promotion status
  Future<Promotion> togglePromotionStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final promotion = await getPromotionById(id);
    if (promotion == null) {
      throw Exception('Promotion not found');
    }

    return promotion.isActive
        ? await deactivatePromotion(id)
        : await activatePromotion(id);
  }
}
