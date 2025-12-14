import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Facility type
enum FacilityType {
  hospital,
  clinic,
  pharmacy,
  healthCenter,
}

/// Facility model
class Facility {
  final String id;
  final String name;
  final FacilityType type;
  final String? address;
  final GeoPoint? location;
  final String? contactPhone;
  final String? contactEmail;
  final List<String> services;
  final double? rating;
  final double? distance; // in km (calculated, not stored)
  final bool isVerified;
  final bool acceptsNHIMA; // National Health Insurance
  final Map<String, String>? operatingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Facility({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.location,
    this.contactPhone,
    this.contactEmail,
    this.services = const [],
    this.rating,
    this.distance,
    this.isVerified = false,
    this.acceptsNHIMA = false,
    this.operatingHours,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Facility from Firestore document
  factory Facility.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Facility(
      id: doc.id,
      name: data['name'] as String,
      type: FacilityType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => FacilityType.clinic,
      ),
      address: data['address'] as String?,
      location: data['location'] as GeoPoint?,
      contactPhone: data['contactPhone'] as String?,
      contactEmail: data['contactEmail'] as String?,
      services: (data['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (data['rating'] as num?)?.toDouble(),
      isVerified: data['isVerified'] as bool? ?? false,
      acceptsNHIMA: data['acceptsNHIMA'] as bool? ?? false,
      operatingHours: data['operatingHours'] as Map<String, String>?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Facility to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      if (address != null) 'address': address,
      if (location != null) 'location': location,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (contactEmail != null) 'contactEmail': contactEmail,
      'services': services,
      if (rating != null) 'rating': rating,
      'isVerified': isVerified,
      'acceptsNHIMA': acceptsNHIMA,
      if (operatingHours != null) 'operatingHours': operatingHours,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Calculate distance from a given location (Haversine formula)
  double? calculateDistance(GeoPoint fromLocation) {
    if (location == null) return null;
    
    return _haversineDistance(
      fromLocation.latitude,
      fromLocation.longitude,
      location!.latitude,
      location!.longitude,
    );
  }
  
  /// Haversine distance calculation (km)
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    const double pi = 3.141592653589793;
    
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (pi / 180)) * math.cos(lat2 * (pi / 180)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
}

