class ItemSize {
  final int id;
  final String sizeName;
  final double additionalPrice;
  final int itemId;
  final DateTime createdAt;

  ItemSize({
    required this.id,
    required this.sizeName,
    required this.additionalPrice,
    required this.itemId,
    required this.createdAt,
  });

  // JSON serialization methods
  factory ItemSize.fromJson(Map<String, dynamic> json) {
    return ItemSize(
      id: json['id'] ?? 0,
      sizeName: json['size_name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0).toDouble(),
      itemId: json['item_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
      'additional_price': additionalPrice,
      'item_id': itemId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
