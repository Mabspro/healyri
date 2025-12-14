import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/facility.dart';
import '../services/facility_service.dart';
import '../services/location_service.dart';
import '../shared/theme.dart';
import '../shared/route_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacilityDirectoryScreen extends StatefulWidget {
  const FacilityDirectoryScreen({Key? key}) : super(key: key);

  @override
  State<FacilityDirectoryScreen> createState() => _FacilityDirectoryScreenState();
}

class _FacilityDirectoryScreenState extends State<FacilityDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FacilityService _facilityService = FacilityService();
  final LocationService _locationService = LocationService();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Hospitals', 'Clinics', 'Pharmacies'];
  String _searchQuery = '';
  GeoPoint? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = location;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  FacilityType? _getFacilityTypeFromFilter(String filter) {
    switch (filter) {
      case 'Hospitals':
        return FacilityType.hospital;
      case 'Clinics':
        return FacilityType.clinic;
      case 'Pharmacies':
        return FacilityType.pharmacy;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Facilities'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search facilities...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Facility>>(
              stream: _facilityService.getAllFacilities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading facilities: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_hospital, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No facilities found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Facilities will appear here once they are added to the system.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter facilities
                List<Facility> facilities = snapshot.data!;
                
                // Apply type filter
                final selectedType = _getFacilityTypeFromFilter(_selectedFilter);
                if (selectedType != null) {
                  facilities = facilities.where((f) => f.type == selectedType).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  facilities = facilities.where((facility) {
                    final name = facility.name.toLowerCase();
                    final address = facility.address?.toLowerCase() ?? '';
                    return name.contains(_searchQuery) || address.contains(_searchQuery);
                  }).toList();
                }

                // Sort by distance if user location is available
                if (_userLocation != null) {
                  facilities.sort((a, b) {
                    final distA = a.distance ?? double.infinity;
                    final distB = b.distance ?? double.infinity;
                    return distA.compareTo(distB);
                  });
                }

                if (facilities.isEmpty) {
                  return const Center(
                    child: Text('No facilities match your search criteria'),
                  );
                }

                return ListView.builder(
                  itemCount: facilities.length,
                  itemBuilder: (context, index) {
                    return _buildFacilityCard(facilities[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Facility facility) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Facility image/icon
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getFacilityIcon(facility.type),
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              // NHIMA banner (with Zambia accent)
              if (facility.acceptsNHIMA)
                Positioned(
                  top: 16,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.zambiaGreen,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.zambiaGreen.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'NHIMA Accepted',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Verified badge (with Zambia accent)
              if (facility.isVerified)
                Positioned(
                  top: 16,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.zambiaAccent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.zambiaAccent.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getFacilityColor(facility.type),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getFacilityTypeLabel(facility.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (facility.address != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(facility.address!)),
                      if (facility.distance != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${facility.distance!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                if (facility.rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${facility.rating!.toStringAsFixed(1)}'),
                    ],
                  ),
                ],
                if (facility.services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Services:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: facility.services.take(5).map((service) {
                      return Chip(
                        label: Text(
                          service,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: const EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (facility.contactPhone != null)
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement call functionality
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement view details
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFacilityIcon(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Icons.local_hospital;
      case FacilityType.clinic:
        return Icons.medical_services;
      case FacilityType.pharmacy:
        return Icons.medication;
      case FacilityType.healthCenter:
        return Icons.health_and_safety;
    }
  }

  Color _getFacilityColor(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;
      case FacilityType.clinic:
        return Colors.blue;
      case FacilityType.pharmacy:
        return Colors.green;
      case FacilityType.healthCenter:
        return Colors.orange;
    }
  }

  String _getFacilityTypeLabel(FacilityType type) {
    switch (type) {
      case FacilityType.hospital:
        return 'Hospital';
      case FacilityType.clinic:
        return 'Clinic';
      case FacilityType.pharmacy:
        return 'Pharmacy';
      case FacilityType.healthCenter:
        return 'Health Center';
    }
  }
}
