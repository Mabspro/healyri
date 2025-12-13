import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../services/facility_service.dart';
import 'resolve_emergency_screen.dart';
import '../core/logger.dart';
import '../core/error_handler.dart';

/// Dashboard for facilities to view and acknowledge emergencies
class EmergencyDashboardScreen extends StatefulWidget {
  const EmergencyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyDashboardScreen> createState() => _EmergencyDashboardScreenState();
}

class _EmergencyDashboardScreenState extends State<EmergencyDashboardScreen> {
  final FacilityService _facilityService = FacilityService();
  String? _facilityId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilityId();
  }

  Future<void> _loadFacilityId() async {
    try {
      final facilityId = await _facilityService.getCurrentUserFacilityId();
      setState(() {
        _facilityId = facilityId;
        _loading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load facility ID', e, stackTrace);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resolveEmergency(Emergency emergency) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResolveEmergencyScreen(emergency: emergency),
      ),
    );
    
    if (result == true && mounted) {
      // Refresh the list
      setState(() {});
    }
  }

  Future<void> _acknowledgeEmergency(String emergencyId) async {
    try {
      await _facilityService.acknowledgeEmergency(emergencyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency acknowledged'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to acknowledge emergency', e, stackTrace);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Error',
          'Failed to acknowledge emergency. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_facilityId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Dashboard'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No facility assigned to your account. Please contact support.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Emergency>>(
        stream: _facilityService.getAssignedEmergencies(_facilityId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final emergencies = snapshot.data ?? [];

          if (emergencies.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No emergencies assigned to your facility',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final emergency = emergencies[index];
              return _buildEmergencyCard(emergency);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmergencyCard(Emergency emergency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency #${emergency.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(emergency.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(emergency.urgency).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    emergency.urgency.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getUrgencyColor(emergency.urgency),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Patient ID', emergency.patientId.substring(0, 8)),
            if (emergency.description != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.description, 'Description', emergency.description!),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(emergency.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(emergency.status),
                    color: _getStatusColor(emergency.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${emergency.status.toString().split('.').last.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(emergency.status),
                    ),
                  ),
                ],
              ),
            ),
            // Driver assignment info (Week 3)
            if (emergency.assignedDriverId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.directions_car,
                'Driver Assigned',
                emergency.assignedDriverId!.substring(0, 8),
              ),
              if (emergency.status == EmergencyStatus.inTransit) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  'ETA',
                  _calculateETA(emergency),
                ),
              ],
            ],
            
            if (emergency.status == EmergencyStatus.dispatched) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _acknowledgeEmergency(emergency.id),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Acknowledge Emergency'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            
            // Resolve button (Week 4)
            if (emergency.status == EmergencyStatus.arrived ||
                emergency.status == EmergencyStatus.inTransit) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _resolveEmergency(emergency),
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Resolve Emergency'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.created:
        return Colors.blue;
      case EmergencyStatus.dispatched:
        return Colors.orange;
      case EmergencyStatus.inTransit:
        return Colors.purple;
      case EmergencyStatus.arrived:
        return Colors.teal;
      case EmergencyStatus.resolved:
        return Colors.green;
      case EmergencyStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.created:
        return Icons.access_time;
      case EmergencyStatus.dispatched:
        return Icons.send;
      case EmergencyStatus.inTransit:
        return Icons.directions_car;
      case EmergencyStatus.arrived:
        return Icons.location_on;
      case EmergencyStatus.resolved:
        return Icons.check_circle;
      case EmergencyStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getUrgencyColor(EmergencyUrgency urgency) {
    switch (urgency) {
      case EmergencyUrgency.critical:
        return Colors.red;
      case EmergencyUrgency.high:
        return Colors.orange;
      case EmergencyUrgency.medium:
        return Colors.amber;
      case EmergencyUrgency.low:
        return Colors.blue;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateETA(Emergency emergency) {
    if (emergency.inTransitAt == null) {
      return 'Calculating ETA...';
    }
    
    final now = DateTime.now();
    final elapsed = now.difference(emergency.inTransitAt!);
    
    // Simple ETA calculation (can be enhanced with real distance/time)
    // Assume average speed of 40 km/h in urban areas
    final estimatedMinutes = 15 + (elapsed.inMinutes * 0.1).round();
    
    if (estimatedMinutes <= 5) {
      return 'Arriving in approximately 5 minutes';
    } else if (estimatedMinutes <= 15) {
      return 'Arriving in approximately $estimatedMinutes minutes';
    } else {
      return 'Estimated arrival: ${estimatedMinutes} minutes';
    }
  }
}

