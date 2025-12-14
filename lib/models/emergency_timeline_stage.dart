import 'package:flutter/material.dart';
import 'emergency.dart';

/// Represents a stage in the emergency timeline
class EmergencyTimelineStage {
  final EmergencyStatus status;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isCurrent;
  final DateTime? timestamp;

  const EmergencyTimelineStage({
    required this.status,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.isCurrent,
    this.timestamp,
  });

  /// Get all stages in order
  static List<EmergencyTimelineStage> getStages(Emergency emergency) {
    final stages = <EmergencyTimelineStage>[];

    // Received
    final receivedAt = emergency.receivedAt ?? emergency.timestamp;
    stages.add(EmergencyTimelineStage(
      status: EmergencyStatus.created,
      label: 'Received',
      description: 'Emergency request received',
      icon: Icons.check_circle_outline,
      color: Colors.green,
      isCompleted: true, // Always completed since emergency exists
      isCurrent: emergency.status == EmergencyStatus.created,
      timestamp: receivedAt,
    ));

    // Assigned
    final assignedAt = emergency.assignedAt;
    stages.add(EmergencyTimelineStage(
      status: EmergencyStatus.dispatched,
      label: 'Assigned',
      description: 'Responder and facility assigned',
      icon: Icons.assignment,
      color: Colors.blue,
      isCompleted: assignedAt != null,
      isCurrent: emergency.status == EmergencyStatus.dispatched,
      timestamp: assignedAt,
    ));

    // En Route
    final enRouteAt = emergency.enRouteAt;
    stages.add(EmergencyTimelineStage(
      status: EmergencyStatus.inTransit,
      label: 'En Route',
      description: 'Help is on the way',
      icon: Icons.directions_car,
      color: Colors.purple,
      isCompleted: enRouteAt != null,
      isCurrent: emergency.status == EmergencyStatus.inTransit,
      timestamp: enRouteAt,
    ));

    // Arrived
    final arrivedAt = emergency.arrivedAt;
    final isArrived = emergency.status == EmergencyStatus.arrived;
    stages.add(EmergencyTimelineStage(
      status: EmergencyStatus.arrived,
      label: 'Arrived',
      description: 'Responder arrived at location',
      icon: Icons.location_on,
      color: Colors.orange,
      isCompleted: arrivedAt != null,
      isCurrent: isArrived,
      timestamp: arrivedAt,
    ));

    // Departed (if applicable)
    if (emergency.departedAt != null || isArrived) {
      stages.add(EmergencyTimelineStage(
        status: EmergencyStatus.arrived, // Reuse status for departed
        label: 'Departed',
        description: 'Transporting to facility',
        icon: Icons.airport_shuttle,
        color: Colors.teal,
        isCompleted: emergency.departedAt != null,
        isCurrent: false,
        timestamp: emergency.departedAt,
      ));
    }

    // Facility Arrived
    if (emergency.facilityArrivedAt != null || emergency.departedAt != null) {
      stages.add(EmergencyTimelineStage(
        status: EmergencyStatus.arrived, // Reuse status
        label: 'At Facility',
        description: 'Arrived at healthcare facility',
        icon: Icons.local_hospital,
        color: Colors.indigo,
        isCompleted: emergency.facilityArrivedAt != null,
        isCurrent: false,
        timestamp: emergency.facilityArrivedAt,
      ));
    }

    // Resolved
    final resolvedAt = emergency.resolvedAt;
    final isResolved = emergency.status == EmergencyStatus.resolved;
    stages.add(EmergencyTimelineStage(
      status: EmergencyStatus.resolved,
      label: 'Resolved',
      description: 'Emergency resolved',
      icon: Icons.check_circle,
      color: Colors.green,
      isCompleted: resolvedAt != null,
      isCurrent: isResolved,
      timestamp: resolvedAt,
    ));

    return stages;
  }
}

