import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../core/logger.dart';

/// Service for facility operations (acknowledgment, viewing emergencies)
class FacilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EventService _eventService = EventService();

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

