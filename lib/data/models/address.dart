class Address {
  final int id;
  final String formattedAddress;
  final String customLabel;
  final double latitude;
  final double longitude;
  final String userId;
  final String regionName; // Only region name shown

  Address({
    required this.id,
    required this.formattedAddress,
    required this.customLabel,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.regionName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      formattedAddress: json['formatted_address'] ?? '',
      customLabel: json['custom_label'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id'] ?? '',
      regionName: json['regions']?['name'] ?? '—', // only the region name
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
      'custom_label': customLabel,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      // No regionName here because we don't insert/edit names, only IDs
    };
  }
}
