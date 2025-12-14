import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/facility.dart';
import '../core/logger.dart';

/// Service for facility operations
class FacilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'facilities';

  /// Get all facilities
  Stream<List<Facility>> getAllFacilities() {
    return _firestore
        .collection(_collectionName)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Facility.fromFirestore(doc))
            .toList());
  }

  /// Get nearby facilities (sorted by distance)
  Future<List<Facility>> getNearbyFacilities({
    GeoPoint? userLocation,
    int limit = 10,
  }) async {
    try {
      // If no user location, return all verified facilities
      if (userLocation == null) {
        final snapshot = await _firestore
            .collection(_collectionName)
            .where('isVerified', isEqualTo: true)
            .limit(limit)
            .get();
        
        return snapshot.docs
            .map((doc) => Facility.fromFirestore(doc))
            .toList();
      }

      // Get all verified facilities
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isVerified', isEqualTo: true)
          .get();

      // Calculate distances and sort
      final facilities = snapshot.docs
          .map((doc) {
            final facility = Facility.fromFirestore(doc);
            final distance = facility.calculateDistance(userLocation);
            return Facility(
              id: facility.id,
              name: facility.name,
              type: facility.type,
              address: facility.address,
              location: facility.location,
              contactPhone: facility.contactPhone,
              contactEmail: facility.contactEmail,
              services: facility.services,
              rating: facility.rating,
              distance: distance,
              isVerified: facility.isVerified,
              acceptsNHIMA: facility.acceptsNHIMA,
              operatingHours: facility.operatingHours,
              createdAt: facility.createdAt,
              updatedAt: facility.updatedAt,
            );
          })
          .where((f) => f.distance != null)
          .toList();

      // Sort by distance
      facilities.sort((a, b) => (a.distance ?? double.infinity)
          .compareTo(b.distance ?? double.infinity));

      return facilities.take(limit).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get nearby facilities', e, stackTrace);
      return [];
    }
  }

  /// Get facility by ID
  Future<Facility?> getFacility(String facilityId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(facilityId)
          .get();

      if (!doc.exists) return null;

      return Facility.fromFirestore(doc);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get facility: $facilityId', e, stackTrace);
      return null;
    }
  }

  /// Get facilities by type
  Stream<List<Facility>> getFacilitiesByType(FacilityType type) {
    return _firestore
        .collection(_collectionName)
        .where('type', isEqualTo: type.toString().split('.').last)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Facility.fromFirestore(doc))
            .toList());
  }

  /// Search facilities by name
  Future<List<Facility>> searchFacilities(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isVerified', isEqualTo: true)
          .get();

      final queryLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => Facility.fromFirestore(doc))
          .where((facility) =>
              facility.name.toLowerCase().contains(queryLower) ||
              (facility.address?.toLowerCase().contains(queryLower) ?? false))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to search facilities', e, stackTrace);
      return [];
    }
  }
}
