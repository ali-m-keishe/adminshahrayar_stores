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

  factory ItemSize.fromJson(Map<String, dynamic> json) {
    return ItemSize(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sizeName: json['size_name'] ?? '',
      additionalPrice: (json['additional_price'] ?? 0).toDouble(),
      itemId: json['item_id'] is int ? json['item_id'] : int.tryParse(json['item_id'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
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
