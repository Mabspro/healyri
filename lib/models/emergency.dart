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
  final DateTime? dispatchedAt;
  final DateTime? inTransitAt;
  final DateTime? arrivedAt;
  final DateTime? resolvedAt;
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
    this.dispatchedAt,
    this.inTransitAt,
    this.arrivedAt,
    this.resolvedAt,
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
      dispatchedAt: data['dispatchedAt'] != null
          ? (data['dispatchedAt'] as Timestamp).toDate()
          : null,
      inTransitAt: data['inTransitAt'] != null
          ? (data['inTransitAt'] as Timestamp).toDate()
          : null,
      arrivedAt: data['arrivedAt'] != null
          ? (data['arrivedAt'] as Timestamp).toDate()
          : null,
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
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
      if (dispatchedAt != null) 'dispatchedAt': Timestamp.fromDate(dispatchedAt!),
      if (inTransitAt != null) 'inTransitAt': Timestamp.fromDate(inTransitAt!),
      if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt!),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
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
    DateTime? dispatchedAt,
    DateTime? inTransitAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
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
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      inTransitAt: inTransitAt ?? this.inTransitAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionOutcome: resolutionOutcome ?? this.resolutionOutcome,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

