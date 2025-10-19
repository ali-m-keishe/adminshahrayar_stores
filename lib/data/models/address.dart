class Address {
  final int id;
  final String customLabel;
  final String blockNumber;
  final String entrance;
  final String floor;
  final String apartment;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String userId;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.customLabel,
    required this.blockNumber,
    required this.entrance,
    required this.floor,
    required this.apartment,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.userId,
    required this.createdAt,
  });

  // JSON serialization methods
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      customLabel: json['custom_label'] ?? '',
      blockNumber: json['block_number'] ?? '',
      entrance: json['entrance'] ?? '',
      floor: json['floor'] ?? '',
      apartment: json['apartment'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      formattedAddress: json['formatted_address'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'custom_label': customLabel,
      'block_number': blockNumber,
      'entrance': entrance,
      'floor': floor,
      'apartment': apartment,
      'latitude': latitude,
      'longitude': longitude,
      'formatted_address': formattedAddress,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
