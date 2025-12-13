import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../services/driver_service.dart';
import '../core/logger.dart';
import '../core/error_handler.dart';

/// Screen for drivers to view and manage emergency trips
class EmergencyTripScreen extends StatefulWidget {
  final Emergency emergency;

  const EmergencyTripScreen({
    Key? key,
    required this.emergency,
  }) : super(key: key);

  @override
  State<EmergencyTripScreen> createState() => _EmergencyTripScreenState();
}

class _EmergencyTripScreenState extends State<EmergencyTripScreen> {
  final DriverService _driverService = DriverService();
  bool _isAccepting = false;
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Trip'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<Emergency?>(
        stream: _driverService.getAssignedEmergencies(
          widget.emergency.assignedDriverId ?? '',
        ).map((list) => list.firstWhere(
          (e) => e.id == widget.emergency.id,
          orElse: () => widget.emergency,
        )),
        builder: (context, snapshot) {
          final emergency = snapshot.data ?? widget.emergency;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emergency Info Card
                _buildEmergencyCard(emergency),
                const SizedBox(height: 24),

                // Action Buttons based on status
                if (emergency.status == EmergencyStatus.dispatched) ...[
                  _buildAcceptButton(emergency),
                ] else if (emergency.status == EmergencyStatus.inTransit) ...[
                  _buildInTransitView(emergency),
                ] else if (emergency.status == EmergencyStatus.arrived) ...[
                  _buildArrivedView(emergency),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyCard(Emergency emergency) {
    return Card(
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
                          fontSize: 20,
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
            _buildInfoRow(Icons.location_on, 'Pickup Location', 
              '${emergency.location.latitude.toStringAsFixed(4)}, ${emergency.location.longitude.toStringAsFixed(4)}'),
            if (emergency.assignedFacilityId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.local_hospital, 'Destination', 'Facility ID: ${emergency.assignedFacilityId!.substring(0, 8)}'),
            ],
            if (emergency.description != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.description, 'Description', emergency.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton(Emergency emergency) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isAccepting ? null : () => _acceptEmergency(emergency.id),
        icon: const Icon(Icons.check_circle),
        label: Text(_isAccepting ? 'Accepting...' : 'Accept Emergency'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInTransitView(Emergency emergency) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.purple, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'In Transit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Help is on the way',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _markArrived(emergency.id),
            icon: const Icon(Icons.location_on),
            label: const Text('Mark as Arrived'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrivedView(Emergency emergency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arrived at Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  emergency.arrivedAt != null
                      ? 'Arrived at ${_formatDateTime(emergency.arrivedAt!)}'
                      : 'Waiting for facility response',
                  style: TextStyle(
                    fontSize: 14,
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

  Future<void> _acceptEmergency(String emergencyId) async {
    setState(() {
      _isAccepting = true;
    });

    try {
      await _driverService.acceptEmergency(emergencyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency accepted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to accept emergency', e, stackTrace);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Error',
          'Failed to accept emergency. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _markArrived(String emergencyId) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _driverService.markArrived(emergencyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as arrived'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to mark as arrived', e, stackTrace);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Error',
          'Failed to mark as arrived. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
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
}

