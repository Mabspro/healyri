import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../core/logger.dart';
import '../core/error_handler.dart';
import 'emergency_commitment_view.dart';

/// Emergency screen that creates a real emergency in the backend
/// Upgraded with quick chips, location confirmation, and commitment view
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  final LocationService _locationService = LocationService();
  
  // Form state
  String? _selectedEmergencyType;
  GeoPoint? _confirmedLocation;
  bool? _canTalk;
  String? _peopleAffected;
  EmergencyUrgency? _selectedUrgency;
  
  bool _isLoadingLocation = false;
  bool _isCreating = false;
  Emergency? _createdEmergency;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _confirmedLocation = location;
          _isLoadingLocation = false;
        });
      } else {
        final lastKnown = await _locationService.getLastKnownLocation();
        setState(() {
          _confirmedLocation = lastKnown;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _createEmergency() async {
    if (_isCreating) return;
    if (_selectedEmergencyType == null || _confirmedLocation == null) {
      ErrorHandler.showErrorDialog(
        context,
        'Missing Information',
        'Please select emergency type and confirm your location.',
      );
      return;
    }

    // Map emergency type to urgency if not explicitly set
    final urgency = _selectedUrgency ?? _getUrgencyFromType(_selectedEmergencyType!);

    setState(() => _isCreating = true);

    try {
      final description = _buildDescription();
      
      final emergency = await _emergencyService.createEmergency(
        location: _confirmedLocation!,
        urgency: urgency,
        description: description,
        metadata: {
          'emergencyType': _selectedEmergencyType,
          'canTalk': _canTalk,
          'peopleAffected': _peopleAffected,
        },
      );
      
      if (mounted) {
        setState(() {
          _createdEmergency = emergency;
          _isCreating = false;
        });
        AppLogger.i('Emergency created successfully: ${emergency.id}');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create emergency', e, stackTrace);
      if (mounted) {
        setState(() => _isCreating = false);
        ErrorHandler.showErrorDialog(
          context,
          'Emergency Error',
          'Failed to create emergency. Please try again.',
        );
      }
    }
  }

  String _buildDescription() {
    final parts = <String>[];
    if (_selectedEmergencyType != null) {
      parts.add('Type: $_selectedEmergencyType');
    }
    if (_canTalk != null) {
      parts.add('Can talk: ${_canTalk! ? "Yes" : "No"}');
    }
    if (_peopleAffected != null) {
      parts.add('People affected: $_peopleAffected');
    }
    return parts.join(' | ');
  }

  EmergencyUrgency _getUrgencyFromType(String type) {
    switch (type) {
      case 'Accident / Injury':
      case 'Breathing / Chest pain':
      case 'Violence / safety':
        return EmergencyUrgency.critical;
      case 'Pregnancy / labor':
      case 'Child emergency':
        return EmergencyUrgency.high;
      default:
        return EmergencyUrgency.medium;
    }
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
          ? EmergencyCommitmentView(emergency: _createdEmergency!)
          : _buildEmergencyFormView(),
    );
  }

  Widget _buildEmergencyFormView() {
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
            'What\'s happening?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Emergency Type Chips
          _buildEmergencyTypeChips(),
          
          const SizedBox(height: 24),
          
          // Location Confirmation
          _buildLocationConfirmation(),
          
          const SizedBox(height: 24),
          
          // Can you talk?
          _buildCanTalkSection(),
          
          const SizedBox(height: 24),
          
          // How many people affected?
          _buildPeopleAffectedSection(),
          
          const SizedBox(height: 32),
          
          // Submit Button
          _buildSubmitButton(),
          
          if (_isCreating) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
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

  Widget _buildEmergencyTypeChips() {
    final types = [
      'Accident / Injury',
      'Breathing / Chest pain',
      'Pregnancy / labor',
      'Child emergency',
      'Violence / safety',
      'Other',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedEmergencyType == type;
        return FilterChip(
          selected: isSelected,
          label: Text(type),
          onSelected: (selected) {
            setState(() {
              _selectedEmergencyType = selected ? type : null;
            });
          },
          selectedColor: Colors.red[100],
          checkmarkColor: Colors.red[700],
          side: BorderSide(
            color: isSelected ? Colors.red[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationConfirmation() {
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
                Icon(Icons.location_on, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Your Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingLocation)
              const Center(child: CircularProgressIndicator())
            else if (_confirmedLocation != null) ...[
              // Human-readable location (placeholder - will be replaced with reverse geocoding)
              Text(
                'Location detected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Near your current position',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Open map to adjust pin location
                        _loadLocation(); // For now, just reload
                      },
                      icon: const Icon(Icons.edit_location_alt, size: 18),
                      label: const Text('Adjust Pin'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Show details (lat/lng) in a dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Location Details'),
                          content: Text(
                            'Latitude: ${_confirmedLocation!.latitude.toStringAsFixed(6)}\n'
                            'Longitude: ${_confirmedLocation!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Unable to determine location',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadLocation,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCanTalkSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Can you talk?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Yes'),
                    selected: _canTalk == true,
                    onSelected: (selected) {
                      setState(() {
                        _canTalk = selected ? true : null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('No'),
                    selected: _canTalk == false,
                    onSelected: (selected) {
                      setState(() {
                        _canTalk = selected ? false : null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleAffectedSection() {
    final options = ['1', '2-5', '6+'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How many people affected?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = _peopleAffected == option;
                return FilterChip(
                  selected: isSelected,
                  label: Text(option),
                  onSelected: (selected) {
                    setState(() {
                      _peopleAffected = selected ? option : null;
                    });
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[700],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedEmergencyType != null && _confirmedLocation != null;
    
    return ElevatedButton(
      onPressed: canSubmit && !_isCreating ? _createEmergency : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Send Emergency Request',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
