enum DiscountType { Percentage, FixedAmount }

class Promotion {
  final String id;
  final String code;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final bool isActive;

  Promotion({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
  });

  // A helper to easily display the discount value
  String get displayValue {
    if (discountType == DiscountType.Percentage) {
      return '${discountValue.toInt()}%';
    }
    return '\$${discountValue.toStringAsFixed(2)}';
  }
}

// Mock data for our UI
final List<Promotion> mockPromotions = [
  Promotion(
    id: 'p1',
    code: 'SAVE20',
    description: '20% off entire order',
    discountType: DiscountType.Percentage,
    discountValue: 20,
    isActive: true,
  ),
  Promotion(
    id: 'p2',
    code: '5OFF',
    description: '\$5 off orders over \$50',
    discountType: DiscountType.FixedAmount,
    discountValue: 5,
    isActive: true,
  ),
  Promotion(
    id: 'p3',
    code: 'FREEDELIVERY',
    description: 'Free delivery on weekends',
    discountType: DiscountType.FixedAmount,
    discountValue: 0, // Represents a non-monetary value
    isActive: false,
  ),
];
