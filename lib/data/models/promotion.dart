class Promotion {
  final int id; // 'bigint' in Supabase maps to int in Dart
  final String name; // This is the promo code, e.g., 'SAVE20'
  final String? description;
  final String discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Promotion({
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  // Helper to display the discount value nicely
  String get displayValue {
    if (discountType.toLowerCase() == 'percentage') {
      return '${discountValue.toInt()}%';
    }
    return '\$${discountValue.toStringAsFixed(2)}';
  }

  // A factory constructor to create a Promotion from a JSON map (data from Supabase)
  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  // A method to convert a Promotion object to a JSON map (to send to Supabase)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
    };
  }
}
