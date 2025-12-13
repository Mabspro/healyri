import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../models/resolution_outcome.dart';
import '../services/emergency_service.dart';
import '../core/logger.dart';
import '../core/error_handler.dart';

/// Screen for providers to resolve emergencies
class ResolveEmergencyScreen extends StatefulWidget {
  final Emergency emergency;

  const ResolveEmergencyScreen({
    Key? key,
    required this.emergency,
  }) : super(key: key);

  @override
  State<ResolveEmergencyScreen> createState() => _ResolveEmergencyScreenState();
}

class _ResolveEmergencyScreenState extends State<ResolveEmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  final TextEditingController _notesController = TextEditingController();
  ResolutionOutcome? _selectedOutcome;
  bool _isResolving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve Emergency'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Info
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency #${widget.emergency.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Patient: ${widget.emergency.patientName ?? widget.emergency.patientId.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Urgency: ${widget.emergency.urgency.toString().split('.').last.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getUrgencyColor(widget.emergency.urgency),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resolution Outcome Selection
            const Text(
              'Resolution Outcome *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ResolutionOutcome.values.map((outcome) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<ResolutionOutcome>(
                  title: Text(
                    outcome.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: _getOutcomeDescription(outcome),
                  value: outcome,
                  groupValue: _selectedOutcome,
                  onChanged: (value) {
                    setState(() {
                      _selectedOutcome = value;
                    });
                  },
                  activeColor: Colors.teal,
                ),
              );
            }),
            const SizedBox(height: 24),

            // Notes (optional)
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter any additional notes about the resolution...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),

            // Resolve Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedOutcome == null || _isResolving
                    ? null
                    : _resolveEmergency,
                icon: const Icon(Icons.check_circle),
                label: Text(_isResolving ? 'Resolving...' : 'Resolve Emergency'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getOutcomeDescription(ResolutionOutcome outcome) {
    switch (outcome) {
      case ResolutionOutcome.admitted:
        return const Text('Patient was admitted to this facility');
      case ResolutionOutcome.referred:
        return const Text('Patient was referred to another facility');
      case ResolutionOutcome.stabilized:
        return const Text('Patient was stabilized and discharged');
      case ResolutionOutcome.deceased:
        return const Text('Patient deceased (critical for healthcare records)');
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

  Future<void> _resolveEmergency() async {
    if (_selectedOutcome == null) return;

    setState(() {
      _isResolving = true;
    });

    try {
      await _emergencyService.resolveEmergency(
        widget.emergency.id,
        _selectedOutcome!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency resolved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to resolve emergency', e, stackTrace);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Error',
          'Failed to resolve emergency. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }
}

