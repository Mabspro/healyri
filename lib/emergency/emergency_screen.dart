import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../core/logger.dart';
import '../core/error_handler.dart';

/// Emergency screen that creates a real emergency in the backend
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  final LocationService _locationService = LocationService();
  bool _isCreating = false;
  Emergency? _createdEmergency;

  Future<void> _createEmergency(EmergencyUrgency urgency) async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Get user location
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        // Try last known location
        final lastKnown = await _locationService.getLastKnownLocation();
        if (lastKnown == null) {
          if (mounted) {
            ErrorHandler.showErrorDialog(
              context,
              'Location Error',
              'Unable to determine your location. Please enable location services and try again.',
            );
          }
          return;
        }
        // Use last known location
        final emergency = await _emergencyService.createEmergency(
          location: lastKnown,
          urgency: urgency,
          description: 'Emergency request created',
        );
        if (mounted) {
          setState(() {
            _createdEmergency = emergency;
          });
        }
        AppLogger.i('Emergency created successfully: ${emergency.id}');
      } else {
        // Use current location
        final emergency = await _emergencyService.createEmergency(
          location: location,
          urgency: urgency,
          description: 'Emergency request created',
        );
        if (mounted) {
          setState(() {
            _createdEmergency = emergency;
          });
        }
        AppLogger.i('Emergency created successfully: ${emergency.id}');
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create emergency', e, stackTrace);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Emergency Error',
          'Failed to create emergency. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Emergency Created'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your emergency request has been created and is being processed.',
              style: TextStyle(fontSize: 16),
            ),
            if (_createdEmergency != null) ...[
              const SizedBox(height: 16),
              Text(
                'Emergency ID: ${_createdEmergency!.id}',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close emergency screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _createdEmergency != null
          ? _buildEmergencyStatusView()
          : _buildEmergencyOptionsView(),
    );
  }

  Widget _buildEmergencyOptionsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(
            Icons.emergency,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Emergency Services',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the urgency level of your emergency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          _buildUrgencyButton(
            'Critical Emergency',
            'Life-threatening situation requiring immediate response',
            EmergencyUrgency.critical,
            Colors.red,
            Icons.warning,
          ),
          const SizedBox(height: 16),
          _buildUrgencyButton(
            'High Priority',
            'Serious situation requiring urgent attention',
            EmergencyUrgency.high,
            Colors.orange,
            Icons.priority_high,
          ),
          const SizedBox(height: 16),
          _buildUrgencyButton(
            'Medium Priority',
            'Moderate situation requiring prompt attention',
            EmergencyUrgency.medium,
            Colors.amber,
            Icons.info,
          ),
          const SizedBox(height: 16),
          _buildUrgencyButton(
            'Low Priority',
            'Non-urgent situation',
            EmergencyUrgency.low,
            Colors.blue,
            Icons.help_outline,
          ),
          if (_isCreating) ...[
            const SizedBox(height: 32),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Creating emergency request...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgencyButton(
    String title,
    String subtitle,
    EmergencyUrgency urgency,
    Color color,
    IconData icon,
  ) {
    return ElevatedButton(
      onPressed: _isCreating ? null : () => _createEmergency(urgency),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }

  Widget _buildEmergencyStatusView() {
    return StreamBuilder<Emergency?>(
      stream: _emergencyService.streamEmergency(_createdEmergency!.id),
      builder: (context, snapshot) {
        final emergency = snapshot.data ?? _createdEmergency;
        if (emergency == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Status',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Status indicator with icon
              _buildStatusIndicator(emergency),
              
              const SizedBox(height: 24),
              _buildStatusCard(
                'Status',
                emergency.status.toString().split('.').last.toUpperCase(),
                _getStatusColor(emergency.status),
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                'Urgency',
                emergency.urgency.toString().split('.').last.toUpperCase(),
                _getUrgencyColor(emergency.urgency),
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                'Created',
                _formatDateTime(emergency.timestamp),
                Colors.grey,
              ),
              
              // Dispatch status
              if (emergency.status == EmergencyStatus.dispatched || 
                  emergency.assignedFacilityId != null) ...[
                const SizedBox(height: 24),
                _buildInfoBanner(
                  Icons.check_circle,
                  Colors.green,
                  'Emergency Received',
                  'Your emergency has been received and is being processed.',
                ),
                const SizedBox(height: 16),
                _buildInfoBanner(
                  Icons.local_hospital,
                  Colors.blue,
                  'Facility Notified',
                  emergency.assignedFacilityId != null
                      ? 'A healthcare facility has been notified and is responding.'
                      : 'Searching for nearest facility...',
                ),
              ],
              
              // Driver assigned status (Week 3)
              if (emergency.assignedDriverId != null) ...[
                const SizedBox(height: 16),
                _buildInfoBanner(
                  Icons.directions_car,
                  Colors.purple,
                  'Driver Assigned',
                  emergency.status == EmergencyStatus.inTransit
                      ? 'Help is on the way! Your driver is en route.'
                      : emergency.status == EmergencyStatus.arrived
                          ? 'Driver has arrived at your location.'
                          : 'A driver has been assigned and will accept shortly.',
                ),
                if (emergency.status == EmergencyStatus.inTransit) ...[
                  const SizedBox(height: 8),
                  _buildInfoBanner(
                    Icons.access_time,
                    Colors.amber,
                    'Estimated Time',
                    _calculateETA(emergency),
                  ),
                ],
              ],
              
              if (emergency.assignedFacilityId != null) ...[
                const SizedBox(height: 16),
                _buildStatusCard(
                  'Facility Assigned',
                  emergency.assignedFacilityId!,
                  Colors.blue,
                ),
              ],
              
              if (emergency.assignedDriverId != null) ...[
                const SizedBox(height: 16),
                _buildStatusCard(
                  'Driver Assigned',
                  emergency.assignedDriverId!.substring(0, 8),
                  Colors.purple,
                ),
              ],
              
              if (emergency.dispatchedAt != null) ...[
                const SizedBox(height: 16),
                _buildStatusCard(
                  'Dispatched At',
                  _formatDateTime(emergency.dispatchedAt!),
                  Colors.orange,
                ),
              ],
              
              if (emergency.inTransitAt != null) ...[
                const SizedBox(height: 16),
                _buildStatusCard(
                  'In Transit Since',
                  _formatDateTime(emergency.inTransitAt!),
                  Colors.purple,
                ),
              ],
              
              if (emergency.arrivedAt != null) ...[
                const SizedBox(height: 16),
                _buildStatusCard(
                  'Arrived At',
                  _formatDateTime(emergency.arrivedAt!),
                  Colors.teal,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(Emergency emergency) {
    IconData icon;
    Color color;
    String message;
    
    switch (emergency.status) {
      case EmergencyStatus.created:
        icon = Icons.access_time;
        color = Colors.blue;
        message = 'Emergency created, waiting for dispatch...';
        break;
      case EmergencyStatus.dispatched:
        icon = Icons.send;
        color = Colors.orange;
        message = 'Emergency dispatched to facility';
        break;
      case EmergencyStatus.inTransit:
        icon = Icons.directions_car;
        color = Colors.purple;
        message = 'Help is on the way';
        break;
      case EmergencyStatus.arrived:
        icon = Icons.location_on;
        color = Colors.teal;
        message = 'Help has arrived';
        break;
      case EmergencyStatus.resolved:
        icon = Icons.check_circle;
        color = Colors.green;
        message = 'Emergency resolved';
        break;
      case EmergencyStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        message = 'Emergency cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(IconData icon, Color color, String title, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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

