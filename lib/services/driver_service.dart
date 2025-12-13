import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/driver.dart';
import '../models/emergency.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../core/logger.dart';

/// Service for driver operations
class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EventService _eventService = EventService();

  static const String _collectionName = 'drivers';

  /// Get driver ID for the current user
  Future<String?> getCurrentUserDriverId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Find driver document by userId
      final driversSnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (driversSnapshot.docs.isNotEmpty) {
        return driversSnapshot.docs.first.id;
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get driver ID for user', e, stackTrace);
      return null;
    }
  }

  /// Get emergencies assigned to the current driver
  Stream<List<Emergency>> getAssignedEmergencies(String driverId) {
    return _firestore
        .collection('emergencies')
        .where('assignedDriverId', isEqualTo: driverId)
        .where('status', whereIn: ['dispatched', 'inTransit', 'arrived'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Emergency.fromFirestore(doc)).toList());
  }

  /// Accept an emergency assignment
  Future<void> acceptEmergency(String emergencyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to accept emergency');
      }

      final driverId = await getCurrentUserDriverId();
      if (driverId == null) {
        throw Exception('No driver profile found for current user');
      }

      // Get the emergency to verify it's assigned to this driver
      final emergencyDoc = await _firestore
          .collection('emergencies')
          .doc(emergencyId)
          .get();

      if (!emergencyDoc.exists) {
        throw Exception('Emergency not found');
      }

      final emergency = Emergency.fromFirestore(emergencyDoc);

      // Verify the emergency is assigned to this driver
      if (emergency.assignedDriverId != driverId) {
        throw Exception('Emergency is not assigned to this driver');
      }

      // Update emergency status to inTransit
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'status': 'inTransit',
        'inTransitAt': FieldValue.serverTimestamp(),
      });

      // Update driver status to onTrip
      await _firestore.collection(_collectionName).doc(driverId).update({
        'status': 'onTrip',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.i('Emergency $emergencyId accepted by driver $driverId');

      // Log the event
      await _eventService.logEvent(
        type: EventType.driverAssigned,
        emergencyId: emergencyId,
        entityId: driverId,
        description: 'Driver accepted emergency assignment',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to accept emergency: $emergencyId', e, stackTrace);
      rethrow;
    }
  }

  /// Mark emergency as arrived
  Future<void> markArrived(String emergencyId) async {
    try {
      final driverId = await getCurrentUserDriverId();
      if (driverId == null) {
        throw Exception('No driver profile found');
      }

      // Verify emergency is assigned to this driver
      final emergencyDoc = await _firestore
          .collection('emergencies')
          .doc(emergencyId)
          .get();

      if (!emergencyDoc.exists) {
        throw Exception('Emergency not found');
      }

      final emergency = Emergency.fromFirestore(emergencyDoc);
      if (emergency.assignedDriverId != driverId) {
        throw Exception('Emergency is not assigned to this driver');
      }

      // Update emergency status to arrived
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'status': 'arrived',
        'arrivedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.i('Emergency $emergencyId marked as arrived by driver $driverId');

      // Log the event
      await _eventService.logEvent(
        type: EventType.emergencyArrived,
        emergencyId: emergencyId,
        entityId: driverId,
        description: 'Driver arrived at emergency location',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to mark emergency as arrived: $emergencyId', e, stackTrace);
      rethrow;
    }
  }

  /// Update driver location
  Future<void> updateLocation(GeoPoint location) async {
    try {
      final driverId = await getCurrentUserDriverId();
      if (driverId == null) return;

      await _firestore.collection(_collectionName).doc(driverId).update({
        'currentLocation': location,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update driver location', e, stackTrace);
    }
  }

  /// Get available drivers near a location
  Future<List<Driver>> getAvailableDriversNearLocation(
    GeoPoint location,
    double radiusKm,
  ) async {
    try {
      // For now, get all available drivers
      // TODO: Implement geospatial query when Firestore supports it
      final driversSnapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'available')
          .where('isVerified', isEqualTo: true)
          .get();

      final drivers = driversSnapshot.docs
          .map((doc) => Driver.fromFirestore(doc))
          .toList();

      // Filter by distance (simple implementation)
      final nearbyDrivers = <Driver>[];
      for (final driver in drivers) {
        if (driver.currentLocation != null) {
          final distance = _calculateDistance(
            location.latitude,
            location.longitude,
            driver.currentLocation!.latitude,
            driver.currentLocation!.longitude,
          );
          if (distance <= radiusKm) {
            nearbyDrivers.add(driver);
          }
        }
      }

      return nearbyDrivers;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get available drivers', e, stackTrace);
      return [];
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRad(lat1).cos() *
            _toRad(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();
    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    return R * c;
  }

  double _toRad(double degrees) => degrees * (3.141592653589793 / 180);

  /// Get completed trips count for a driver (resolved emergencies)
  Future<int> getCompletedTripsCount(String driverId, {DateTime? startDate}) async {
    try {
      Query query = _firestore
          .collection('emergencies')
          .where('assignedDriverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'resolved');

      if (startDate != null) {
        query = query.where('resolvedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get completed trips count', e, stackTrace);
      return 0;
    }
  }

  /// Get today's completed trips count
  Future<int> getTodayCompletedTripsCount(String driverId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection('emergencies')
          .where('assignedDriverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'resolved')
          .where('resolvedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      return snapshot.docs.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get today completed trips count', e, stackTrace);
      return 0;
    }
  }

  /// Calculate earnings for a driver
  /// For now, uses a simple calculation: fixed amount per resolved emergency
  /// TODO: Implement more sophisticated calculation based on distance, time, etc.
  Future<double> calculateEarnings(String driverId, {DateTime? startDate}) async {
    try {
      Query query = _firestore
          .collection('emergencies')
          .where('assignedDriverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'resolved');

      if (startDate != null) {
        query = query.where('resolvedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      final snapshot = await query.get();
      
      // Simple calculation: 50 ZMW per resolved emergency
      // TODO: Replace with actual payment calculation from emergency metadata or separate payments collection
      const double amountPerTrip = 50.0;
      return snapshot.docs.length * amountPerTrip;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to calculate earnings', e, stackTrace);
      return 0.0;
    }
  }

  /// Get today's earnings
  Future<double> getTodayEarnings(String driverId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection('emergencies')
          .where('assignedDriverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'resolved')
          .where('resolvedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      // Simple calculation: 50 ZMW per resolved emergency
      const double amountPerTrip = 50.0;
      return snapshot.docs.length * amountPerTrip;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get today earnings', e, stackTrace);
      return 0.0;
    }
  }

  /// Get all resolved emergencies for a driver (for history)
  Stream<List<Emergency>> getCompletedEmergencies(String driverId) {
    return _firestore
        .collection('emergencies')
        .where('assignedDriverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'resolved')
        .orderBy('resolvedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Emergency.fromFirestore(doc)).toList());
  }
}

// Extension for math operations
extension MathExtensions on num {
  double sin() => (this as double).sin();
  double cos() => (this as double).cos();
  double sqrt() => (this as double).sqrt();
  double atan2(num other) => (this as double).atan2(other as double);
}

