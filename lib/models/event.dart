import 'package:cloud_firestore/cloud_firestore.dart';

/// Event types for audit trail
enum EventType {
  emergencyCreated,
  emergencyDispatched,
  driverAssigned,
  facilityAcknowledged,
  emergencyInTransit,
  emergencyArrived,
  emergencyResolved,
  emergencyCancelled,
}

/// Event model for append-only audit log
class Event {
  final String id;
  final EventType type;
  final DateTime timestamp;
  final String? userId;
  final String? emergencyId;
  final String? entityId; // facilityId, driverId, etc.
  final Map<String, dynamic>? data;
  final String? description;

  Event({
    required this.id,
    required this.type,
    required this.timestamp,
    this.userId,
    this.emergencyId,
    this.entityId,
    this.data,
    this.description,
  });

  /// Create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final eventData = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == eventData['type'],
        orElse: () => EventType.emergencyCreated,
      ),
      timestamp: (eventData['timestamp'] as Timestamp).toDate(),
      userId: eventData['userId'] as String?,
      emergencyId: eventData['emergencyId'] as String?,
      entityId: eventData['entityId'] as String?,
      data: eventData['data'] as Map<String, dynamic>?,
      description: eventData['description'] as String?,
    );
  }

  /// Convert Event to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      if (userId != null) 'userId': userId,
      if (emergencyId != null) 'emergencyId': emergencyId,
      if (entityId != null) 'entityId': entityId,
      if (data != null) 'data': data,
      if (description != null) 'description': description,
    };
  }
}

