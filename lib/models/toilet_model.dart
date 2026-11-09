class ToiletModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final bool waterAvailable;
  final bool soapAvailable;
  final bool wheelchairAccessible;
  final String verificationStatus; // 'verified', 'unverified', 'maintenance'
  final DateTime createdAt;
  final double averageRating;
  final int reviewCount;
  final double? distanceKm; // Computed dynamically via Geolocator

  ToiletModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.waterAvailable = true,
    this.soapAvailable = true,
    this.wheelchairAccessible = false,
    this.verificationStatus = 'verified',
    required this.createdAt,
    this.averageRating = 4.0,
    this.reviewCount = 0,
    this.distanceKm,
  });

  bool get isVerified => verificationStatus.toLowerCase() == 'verified';

  ToiletModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    bool? waterAvailable,
    bool? soapAvailable,
    bool? wheelchairAccessible,
    String? verificationStatus,
    DateTime? createdAt,
    double? averageRating,
    int? reviewCount,
    double? distanceKm,
  }) {
    return ToiletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      waterAvailable: waterAvailable ?? this.waterAvailable,
      soapAvailable: soapAvailable ?? this.soapAvailable,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  factory ToiletModel.fromJson(Map<String, dynamic> json) {
    return ToiletModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Public Restroom',
      address: json['address'] as String? ?? 'Location unavailable',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      waterAvailable: json['water_available'] as bool? ?? true,
      soapAvailable: json['soap_available'] as bool? ?? true,
      wheelchairAccessible: json['wheelchair_accessible'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'verified',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          4.2,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'water_available': waterAvailable,
      'soap_available': soapAvailable,
      'wheelchair_accessible': wheelchairAccessible,
      'verification_status': verificationStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
