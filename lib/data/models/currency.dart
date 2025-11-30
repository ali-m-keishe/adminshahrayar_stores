class Currency {
  final int id;
  final String code;
  final String name;
  final String symbol;
  final double? exchangeRate;
  final bool? isDefault;
  final DateTime createdAt;

  Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    this.exchangeRate,
    this.isDefault,
    required this.createdAt,
  });

  // JSON serialization methods
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      exchangeRate: json['exchange_rate'] != null
          ? (json['exchange_rate'] as num).toDouble()
          : null,
      isDefault: json['is_default'] as bool?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchange_rate': exchangeRate,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields for editing
  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
  }) {
    return Currency(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      exchangeRate: exchangeRate,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }
}

