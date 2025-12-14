import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency.dart';
import '../shared/emergency_components.dart';

/// Emergency Commitment View - The emotional center of the app
/// Shows immediate reassurance after emergency trigger
class EmergencyCommitmentView extends StatefulWidget {
  final Emergency emergency;

  const EmergencyCommitmentView({
    Key? key,
    required this.emergency,
  }) : super(key: key);

  @override
  State<EmergencyCommitmentView> createState() => _EmergencyCommitmentViewState();
}

class _EmergencyCommitmentViewState extends State<EmergencyCommitmentView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Responder data
  Map<String, dynamic>? _responderData;
  bool _loadingResponder = false;
  
  // Facility data
  Map<String, dynamic>? _facilityData;
  bool _loadingFacility = false;

  @override
  void initState() {
    super.initState();
    _loadResponderData();
    _loadFacilityData();
  }

  Future<void> _loadResponderData() async {
    if (widget.emergency.assignedDriverId == null) return;
    
    setState(() => _loadingResponder = true);
    try {
      final driverDoc = await _firestore
          .collection('drivers')
          .doc(widget.emergency.assignedDriverId)
          .get();
      
      if (driverDoc.exists) {
        final driverData = driverDoc.data();
        final userDoc = await _firestore
            .collection('users')
            .doc(driverData?['userId'])
            .get();
        
        setState(() {
          _responderData = {
            'id': driverDoc.id,
            'name': userDoc.data()?['name'] ?? 'Responder',
            'photoUrl': userDoc.data()?['photoUrl'],
            'vehicleType': driverData?['vehicleType'] ?? 'Vehicle',
            'isVerified': driverData?['isVerified'] ?? false,
          };
          _loadingResponder = false;
        });
      }
    } catch (e) {
      setState(() => _loadingResponder = false);
    }
  }

  Future<void> _loadFacilityData() async {
    if (widget.emergency.assignedFacilityId == null) return;
    
    setState(() => _loadingFacility = true);
    try {
      final facilityDoc = await _firestore
          .collection('facilities')
          .doc(widget.emergency.assignedFacilityId)
          .get();
      
      if (facilityDoc.exists) {
        final facilityData = facilityDoc.data();
        setState(() {
          _facilityData = {
            'id': facilityDoc.id,
            'name': facilityData?['name'] ?? 'Healthcare Facility',
            'isReady': facilityData?['emergencyAcceptanceStatus'] == 'available',
          };
          _loadingFacility = false;
        });
      }
    } catch (e) {
      setState(() => _loadingFacility = false);
    }
  }

  String _getNextStepMessage() {
    switch (widget.emergency.status) {
      case EmergencyStatus.created:
        return 'Assigning nearest responder...';
      case EmergencyStatus.dispatched:
        if (widget.emergency.assignedDriverId == null) {
          return 'Searching for available responder...';
        }
        return 'Responder will accept shortly...';
      case EmergencyStatus.inTransit:
        return 'Help is on the way!';
      case EmergencyStatus.arrived:
        return 'Responder has arrived at your location';
      case EmergencyStatus.resolved:
        return 'Emergency resolved';
      case EmergencyStatus.cancelled:
        return 'Emergency cancelled';
    }
  }

  String _formatElapsedTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _callDispatch() async {
    // TODO: Replace with actual dispatch number
    const phoneNumber = 'tel:+260991234567'; // Placeholder
    final uri = Uri.parse(phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS() async {
    // TODO: Replace with actual SMS number
    const smsNumber = 'sms:+260991234567'; // Placeholder
    final uri = Uri.parse(smsNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callResponder() async {
    if (_responderData == null) return;
    // TODO: Get responder phone from driver document
    const phoneNumber = 'tel:+260991234567'; // Placeholder
    final uri = Uri.parse(phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callFacility() async {
    if (_facilityData == null) return;
    // TODO: Get facility phone from facility document
    const phoneNumber = 'tel:+260991234567'; // Placeholder
    final uri = Uri.parse(phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String? _calculateETA() {
    if (widget.emergency.status != EmergencyStatus.inTransit) return null;
    // TODO: Calculate actual ETA based on distance and speed
    return '~15 minutes';
  }

  String? _calculateDistance() {
    if (_facilityData == null) return null;
    // TODO: Calculate actual distance from emergency location to facility
    return '~5 km';
  }

  @override
  Widget build(BuildContext context) {
    final elapsedTime = widget.emergency.elapsedTime ?? Duration.zero;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Received',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    EmergencyStatusChip(
                      status: widget.emergency.status,
                      urgency: widget.emergency.urgency,
                    ),
                  ],
                ),
              ),
              // Elapsed Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Elapsed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TickerBuilder(
                      builder: (context, elapsed) {
                        final totalElapsed = elapsedTime + elapsed;
                        return Text(
                          _formatElapsedTime(totalElapsed),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Next Step Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getNextStepMessage(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Fallback Actions (Always Prominent)
          FallbackActionBar(
            onCallDispatch: _callDispatch,
            onSMSBackup: _sendSMS,
            showSMS: true,
          ),
          
          const SizedBox(height: 24),
          
          // Safety Microcopy
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Safety Reminder',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'If you are in immediate danger, move to safety if possible.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep phone charged; we'll update you in real time.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Responder Card
          if (widget.emergency.assignedDriverId != null)
            ResponderCard(
              responderId: widget.emergency.assignedDriverId,
              responderName: _responderData?['name'],
              responderPhotoUrl: _responderData?['photoUrl'],
              vehicleType: _responderData?['vehicleType'],
              isVerified: _responderData?['isVerified'] ?? false,
              eta: _calculateETA(),
              onCall: _callResponder,
            )
          else
            const ResponderCard(), // Shows placeholder
          
          const SizedBox(height: 16),
          
          // Facility Card
          if (widget.emergency.assignedFacilityId != null)
            FacilityCard(
              facilityId: widget.emergency.assignedFacilityId,
              facilityName: _facilityData?['name'],
              distance: _calculateDistance(),
              isReady: _facilityData?['isReady'] ?? false,
              onContact: _callFacility,
            )
          else
            const FacilityCard(), // Shows placeholder
          
          const SizedBox(height: 24),
          
          // Timeline
          EmergencyTimelineWidget(emergency: widget.emergency),
        ],
      ),
    );
  }
}

/// TickerBuilder - Rebuilds widget periodically for timer updates
class TickerBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Duration elapsed) builder;
  final Duration interval;

  const TickerBuilder({
    Key? key,
    required this.builder,
    this.interval = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder> {
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    Future.delayed(widget.interval, () {
      if (mounted) {
        setState(() {
          _elapsed += widget.interval;
        });
        _startTicker();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _elapsed);
  }
}

