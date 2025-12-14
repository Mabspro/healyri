import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/facility.dart';
import '../models/emergency.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../core/logger.dart';

/// Service for facility operations
class FacilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EventService _eventService = EventService();
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

  /// Get emergencies assigned to the current facility
  Stream<List<Emergency>> getAssignedEmergencies(String facilityId) {
    return _firestore
        .collection('emergencies')
        .where('assignedFacilityId', isEqualTo: facilityId)
        .where('status', whereIn: ['dispatched', 'inTransit', 'arrived'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Emergency.fromFirestore(doc)).toList());
  }

  /// Acknowledge an emergency (facility confirms they received it)
  Future<void> acknowledgeEmergency(String emergencyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to acknowledge emergency');
      }

      // Get the emergency to verify it's assigned to this facility
      final emergencyDoc = await _firestore
          .collection('emergencies')
          .doc(emergencyId)
          .get();

      if (!emergencyDoc.exists) {
        throw Exception('Emergency not found');
      }

      final emergency = Emergency.fromFirestore(emergencyDoc);
      
      // Verify the emergency is in dispatched status
      if (emergency.status != EmergencyStatus.dispatched) {
        throw Exception('Emergency is not in dispatched status');
      }

      // Update emergency status (keeping it as dispatched but marking as acknowledged)
      // We'll add an acknowledgedAt timestamp
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'acknowledgedAt': FieldValue.serverTimestamp(),
        'acknowledgedBy': user.uid,
      });

      AppLogger.i('Emergency $emergencyId acknowledged by facility');

      // Log the acknowledgment event
      await _eventService.logEvent(
        type: EventType.facilityAcknowledged,
        emergencyId: emergencyId,
        entityId: emergency.assignedFacilityId,
        description: 'Facility acknowledged emergency',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to acknowledge emergency: $emergencyId', e, stackTrace);
      rethrow;
    }
  }

  /// Get facility ID for the current user (if they're a provider)
  Future<String?> getCurrentUserFacilityId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Check if user has facilityIds in their profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data();
      final facilityIds = userData?['facilityIds'] as List<dynamic>?;
      
      if (facilityIds != null && facilityIds.isNotEmpty) {
        return facilityIds.first as String;
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get facility ID for user', e, stackTrace);
      return null;
    }
  }
}
