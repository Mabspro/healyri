import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency.dart';
import '../services/emergency_service.dart';

/// Dashboard for viewing emergency response metrics (Week 4)
class EmergencyMetricsScreen extends StatefulWidget {
  const EmergencyMetricsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyMetricsScreen> createState() => _EmergencyMetricsScreenState();
}

class _EmergencyMetricsScreenState extends State<EmergencyMetricsScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Metrics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('emergencies')
            .where('status', isEqualTo: 'resolved')
            .orderBy('resolvedAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final emergencies = snapshot.data?.docs
                  .map((doc) => Emergency.fromFirestore(doc))
                  .toList() ??
              [];

          if (emergencies.isEmpty) {
            return const Center(
              child: Text('No resolved emergencies yet'),
            );
          }

          // Calculate aggregate metrics
          final metrics = _calculateAggregateMetrics(emergencies);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(metrics),
                const SizedBox(height: 24),

                // Recent Resolved Emergencies
                const Text(
                  'Recent Resolved Emergencies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...emergencies.take(10).map((emergency) {
                  return _buildEmergencyMetricsCard(emergency);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Resolved',
            '${metrics['totalResolved']}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Dispatch Time',
            _formatDuration(metrics['avgDispatchTime']),
            Icons.send,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
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
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyMetricsCard(Emergency emergency) {
    final metrics = _emergencyService.calculateMetrics(emergency);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emergency #${emergency.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'RESOLVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (metrics['timeToDispatch'] != null)
              _buildMetricRow(
                'Time to Dispatch',
                _formatDuration(metrics['timeToDispatch']),
                Icons.send,
              ),
            if (metrics['timeToArrival'] != null)
              _buildMetricRow(
                'Time to Arrival',
                _formatDuration(metrics['timeToArrival']),
                Icons.location_on,
              ),
            if (metrics['timeToResolution'] != null)
              _buildMetricRow(
                'Time to Resolution',
                _formatDuration(metrics['timeToResolution']),
                Icons.check_circle,
              ),
            if (emergency.resolutionOutcome != null) ...[
              const SizedBox(height: 8),
              _buildMetricRow(
                'Outcome',
                emergency.resolutionOutcome!,
                Icons.medical_services,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateAggregateMetrics(List<Emergency> emergencies) {
    int totalResolved = emergencies.length;
    Duration totalDispatchTime = Duration.zero;
    int dispatchCount = 0;

    for (final emergency in emergencies) {
      final metrics = _emergencyService.calculateMetrics(emergency);
      if (metrics['timeToDispatch'] != null) {
        totalDispatchTime += metrics['timeToDispatch'] as Duration;
        dispatchCount++;
      }
    }

    final avgDispatchTime = dispatchCount > 0
        ? Duration(milliseconds: totalDispatchTime.inMilliseconds ~/ dispatchCount)
        : null;

    return {
      'totalResolved': totalResolved,
      'avgDispatchTime': avgDispatchTime,
    };
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds}s';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }
}

