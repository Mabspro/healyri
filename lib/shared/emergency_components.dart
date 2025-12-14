import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../models/emergency_timeline_stage.dart';
import '../shared/theme.dart';

/// Emergency Status Chip - Color-coded status indicator
class EmergencyStatusChip extends StatelessWidget {
  final EmergencyStatus status;
  final EmergencyUrgency? urgency;
  final bool compact;

  const EmergencyStatusChip({
    Key? key,
    required this.status,
    this.urgency,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _getStatusInfo(status, urgency);
    
    return Chip(
      avatar: Icon(icon, size: compact ? 16 : 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 12 : 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1.5),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
    );
  }

  (String, Color, IconData) _getStatusInfo(EmergencyStatus status, EmergencyUrgency? urgency) {
    switch (status) {
      case EmergencyStatus.created:
        return ('Received', AppTheme.zambiaGreen, Icons.check_circle_outline);
      case EmergencyStatus.dispatched:
        return ('Assigned', AppTheme.primaryColor, Icons.assignment);
      case EmergencyStatus.inTransit:
        return ('En Route', AppTheme.zambiaOrange, Icons.directions_car);
      case EmergencyStatus.arrived:
        return ('Arrived', AppTheme.warningColor, Icons.location_on);
      case EmergencyStatus.resolved:
        return ('Resolved', AppTheme.zambiaGreen, Icons.check_circle);
      case EmergencyStatus.cancelled:
        return ('Cancelled', Colors.grey, Icons.cancel);
    }
  }
}

/// Emergency Timeline Widget - Visual timeline of emergency stages
class EmergencyTimelineWidget extends StatelessWidget {
  final Emergency emergency;

  const EmergencyTimelineWidget({
    Key? key,
    required this.emergency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stages = EmergencyTimelineStage.getStages(emergency);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final isLast = index == stages.length - 1;
          
          return _TimelineItem(
            stage: stage,
            isLast: isLast,
          );
        }).toList(),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final EmergencyTimelineStage stage;
  final bool isLast;

  const _TimelineItem({
    required this.stage,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and icon
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stage.isCompleted || stage.isCurrent
                    ? stage.color
                    : Colors.grey[300],
                border: Border.all(
                  color: stage.isCurrent ? stage.color : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Icon(
                stage.icon,
                color: stage.isCompleted || stage.isCurrent
                    ? Colors.white
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: stage.isCompleted ? stage.color : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Stage info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    stage.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: stage.isCompleted || stage.isCurrent
                          ? stage.color
                          : Colors.grey[600],
                    ),
                  ),
                  if (stage.isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: stage.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: stage.color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                stage.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              if (stage.timestamp != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(stage.timestamp!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Fallback Action Bar - Call dispatch + SMS backup buttons
class FallbackActionBar extends StatelessWidget {
  final VoidCallback? onCallDispatch;
  final VoidCallback? onSMSBackup;
  final bool showSMS;

  const FallbackActionBar({
    Key? key,
    this.onCallDispatch,
    this.onSMSBackup,
    this.showSMS = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Need immediate help?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCallDispatch ?? () {
                    // Default: Open phone dialer
                    // TODO: Replace with actual dispatch number
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call Dispatch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (showSMS) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSMSBackup ?? () {
                      // Default: Open SMS
                      // TODO: Replace with actual SMS functionality
                    },
                    icon: const Icon(Icons.sms, size: 18),
                    label: const Text('SMS Backup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Responder Card - Shows responder info with verified badge + ETA
class ResponderCard extends StatelessWidget {
  final String? responderId;
  final String? responderName;
  final String? responderPhotoUrl;
  final String? vehicleType;
  final bool isVerified;
  final String? eta;
  final VoidCallback? onCall;

  const ResponderCard({
    Key? key,
    this.responderId,
    this.responderName,
    this.responderPhotoUrl,
    this.vehicleType,
    this.isVerified = false,
    this.eta,
    this.onCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (responderId == null) {
      return _buildPlaceholder();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Responder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.zambiaGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.zambiaGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: AppTheme.zambiaGreen),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.zambiaGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundImage: responderPhotoUrl != null
                      ? NetworkImage(responderPhotoUrl!)
                      : null,
                  child: responderPhotoUrl == null
                      ? Text(
                          responderName?.substring(0, 1).toUpperCase() ?? 'R',
                          style: const TextStyle(fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name and vehicle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        responderName ?? 'Responder',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicleType != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getVehicleIcon(vehicleType!),
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vehicleType!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Call button
                if (onCall != null)
                  IconButton(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone),
                    color: Colors.blue,
                    iconSize: 28,
                  ),
              ],
            ),
            if (eta != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'ETA: $eta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assigning responder...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Finding nearest available responder',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'ambulance':
        return Icons.medical_services;
      case 'taxi':
      case 'car':
        return Icons.directions_car;
      case 'bike':
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'tri-wheel':
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }
}

/// Facility Card - Shows facility info with readiness indicator
class FacilityCard extends StatelessWidget {
  final String? facilityId;
  final String? facilityName;
  final String? distance;
  final bool isReady;
  final VoidCallback? onContact;

  const FacilityCard({
    Key? key,
    this.facilityId,
    this.facilityName,
    this.distance,
    this.isReady = false,
    this.onContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (facilityId == null) {
      return _buildPlaceholder();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Receiving Facility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                // Readiness indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isReady ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isReady ? Icons.check_circle : Icons.pending,
                        size: 14,
                        color: isReady ? Colors.green[700] : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isReady ? 'Ready' : 'Preparing',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isReady ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_hospital, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facilityName ?? 'Healthcare Facility',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (distance != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              distance!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (onContact != null)
                  IconButton(
                    onPressed: onContact,
                    icon: const Icon(Icons.phone),
                    color: Colors.blue,
                    iconSize: 28,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecting facility...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Finding nearest available facility',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

