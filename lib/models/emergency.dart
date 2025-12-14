import 'package:cloud_firestore/cloud_firestore.dart';

/// Emergency urgency levels
enum EmergencyUrgency {
  low,
  medium,
  high,
  critical,
}

/// Emergency lifecycle states
enum EmergencyStatus {
  created,
  dispatched,
  inTransit,
  arrived,
  resolved,
  cancelled,
}

/// Emergency model representing a real emergency request
class Emergency {
  final String id;
  final String patientId;
  final String? patientName;
  final DateTime timestamp;
  final GeoPoint location;
  final EmergencyUrgency urgency;
  final EmergencyStatus status;
  final String? description;
  final String? assignedFacilityId;
  final String? assignedDriverId;
  
  // Canonical timestamps for state machine (all nullable for partial data support)
  final DateTime? receivedAt;        // When emergency was created/received
  final DateTime? assignedAt;        // When responder/facility was assigned
  final DateTime? enRouteAt;          // When responder started moving (inTransit)
  final DateTime? arrivedAt;          // When responder arrived at patient location
  final DateTime? departedAt;         // When transport departed from patient location
  final DateTime? facilityArrivedAt;  // When arrived at facility
  final DateTime? resolvedAt;          // When emergency was resolved
  
  // Legacy timestamps (kept for backward compatibility, map to canonical)
  final DateTime? dispatchedAt;       // Maps to assignedAt
  final DateTime? inTransitAt;        // Maps to enRouteAt
  
  final String? resolutionOutcome;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final Map<String, dynamic>? metadata;

  Emergency({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.timestamp,
    required this.location,
    required this.urgency,
    this.status = EmergencyStatus.created,
    this.description,
    this.assignedFacilityId,
    this.assignedDriverId,
    this.receivedAt,
    this.assignedAt,
    this.enRouteAt,
    this.arrivedAt,
    this.departedAt,
    this.facilityArrivedAt,
    this.resolvedAt,
    // Legacy timestamps
    this.dispatchedAt,
    this.inTransitAt,
    this.resolutionOutcome,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.metadata,
  });

  /// Create Emergency from Firestore document
  factory Emergency.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Emergency(
      id: doc.id,
      patientId: data['patientId'] as String,
      patientName: data['patientName'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      location: data['location'] as GeoPoint,
      urgency: EmergencyUrgency.values.firstWhere(
        (e) => e.toString().split('.').last == data['urgency'],
        orElse: () => EmergencyUrgency.medium,
      ),
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => EmergencyStatus.created,
      ),
      description: data['description'] as String?,
      assignedFacilityId: data['assignedFacilityId'] as String?,
      assignedDriverId: data['assignedDriverId'] as String?,
      // Canonical timestamps
      receivedAt: data['receivedAt'] != null
          ? (data['receivedAt'] as Timestamp).toDate()
          : (data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null),
      assignedAt: data['assignedAt'] != null
          ? (data['assignedAt'] as Timestamp).toDate()
          : (data['dispatchedAt'] != null ? (data['dispatchedAt'] as Timestamp).toDate() : null),
      enRouteAt: data['enRouteAt'] != null
          ? (data['enRouteAt'] as Timestamp).toDate()
          : (data['inTransitAt'] != null ? (data['inTransitAt'] as Timestamp).toDate() : null),
      arrivedAt: data['arrivedAt'] != null
          ? (data['arrivedAt'] as Timestamp).toDate()
          : null,
      departedAt: data['departedAt'] != null
          ? (data['departedAt'] as Timestamp).toDate()
          : null,
      facilityArrivedAt: data['facilityArrivedAt'] != null
          ? (data['facilityArrivedAt'] as Timestamp).toDate()
          : null,
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      // Legacy timestamps (for backward compatibility)
      dispatchedAt: data['dispatchedAt'] != null
          ? (data['dispatchedAt'] as Timestamp).toDate()
          : null,
      inTransitAt: data['inTransitAt'] != null
          ? (data['inTransitAt'] as Timestamp).toDate()
          : null,
      resolutionOutcome: data['resolutionOutcome'] as String?,
      acknowledgedAt: data['acknowledgedAt'] != null
          ? (data['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: data['acknowledgedBy'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Emergency to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      if (patientName != null) 'patientName': patientName,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'urgency': urgency.toString().split('.').last,
      'status': status.toString().split('.').last,
      if (description != null) 'description': description,
      if (assignedFacilityId != null) 'assignedFacilityId': assignedFacilityId,
      if (assignedDriverId != null) 'assignedDriverId': assignedDriverId,
      // Canonical timestamps
      if (receivedAt != null) 'receivedAt': Timestamp.fromDate(receivedAt!),
      if (assignedAt != null) 'assignedAt': Timestamp.fromDate(assignedAt!),
      if (enRouteAt != null) 'enRouteAt': Timestamp.fromDate(enRouteAt!),
      if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt!),
      if (departedAt != null) 'departedAt': Timestamp.fromDate(departedAt!),
      if (facilityArrivedAt != null) 'facilityArrivedAt': Timestamp.fromDate(facilityArrivedAt!),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      // Legacy timestamps (for backward compatibility)
      if (dispatchedAt != null) 'dispatchedAt': Timestamp.fromDate(dispatchedAt!),
      if (inTransitAt != null) 'inTransitAt': Timestamp.fromDate(inTransitAt!),
      if (resolutionOutcome != null) 'resolutionOutcome': resolutionOutcome,
      if (acknowledgedAt != null) 'acknowledgedAt': Timestamp.fromDate(acknowledgedAt!),
      if (acknowledgedBy != null) 'acknowledgedBy': acknowledgedBy,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Emergency copyWith({
    String? id,
    String? patientId,
    String? patientName,
    DateTime? timestamp,
    GeoPoint? location,
    EmergencyUrgency? urgency,
    EmergencyStatus? status,
    String? description,
    String? assignedFacilityId,
    String? assignedDriverId,
    DateTime? receivedAt,
    DateTime? assignedAt,
    DateTime? enRouteAt,
    DateTime? arrivedAt,
    DateTime? departedAt,
    DateTime? facilityArrivedAt,
    DateTime? resolvedAt,
    DateTime? dispatchedAt,
    DateTime? inTransitAt,
    String? resolutionOutcome,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    Map<String, dynamic>? metadata,
  }) {
    return Emergency(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      description: description ?? this.description,
      assignedFacilityId: assignedFacilityId ?? this.assignedFacilityId,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      receivedAt: receivedAt ?? this.receivedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      enRouteAt: enRouteAt ?? this.enRouteAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      departedAt: departedAt ?? this.departedAt,
      facilityArrivedAt: facilityArrivedAt ?? this.facilityArrivedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      inTransitAt: inTransitAt ?? this.inTransitAt,
      resolutionOutcome: resolutionOutcome ?? this.resolutionOutcome,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Get elapsed time since emergency was received
  Duration? get elapsedTime {
    final start = receivedAt ?? timestamp;
    return DateTime.now().difference(start);
  }
  
  /// Get timestamp for a specific stage (safe, returns null if not reached)
  DateTime? getTimestampForStage(EmergencyStatus stage) {
    switch (stage) {
      case EmergencyStatus.created:
        return receivedAt ?? timestamp;
      case EmergencyStatus.dispatched:
        return assignedAt;
      case EmergencyStatus.inTransit:
        return enRouteAt;
      case EmergencyStatus.arrived:
        return arrivedAt;
      case EmergencyStatus.resolved:
        return resolvedAt;
      case EmergencyStatus.cancelled:
        return null;
    }
  }
  
  /// Check if a stage has been reached (has timestamp)
  bool hasReachedStage(EmergencyStatus stage) {
    return getTimestampForStage(stage) != null;
  }
}

