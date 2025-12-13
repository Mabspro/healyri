import 'package:flutter/material.dart';

class FacilityDirectoryScreen extends StatefulWidget {
  const FacilityDirectoryScreen({Key? key}) : super(key: key);

  @override
  State<FacilityDirectoryScreen> createState() => _FacilityDirectoryScreenState();
}

class _FacilityDirectoryScreenState extends State<FacilityDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Hospitals', 'Clinics', 'Pharmacies'];

  final List<HealthcareFacility> _facilities = [
    HealthcareFacility(
      id: '1',
      name: 'Lusaka General Hospital',
      type: 'Hospital',
      address: '123 Independence Ave, Lusaka',
      distance: 2.5,
      rating: 4.2,
      services: ['Emergency', 'Surgery', 'Pediatrics', 'Maternity'],
      imageUrl: 'assets/images/hospital1.jpg',
      acceptsNHIMA: true, // Participates in National Health Insurance
    ),
    HealthcareFacility(
      id: '2',
      name: 'Kanyama Clinic',
      type: 'Clinic',
      address: '45 Kanyama Road, Lusaka',
      distance: 1.2,
      rating: 3.8,
      services: ['General Medicine', 'Vaccinations', 'HIV Testing'],
      imageUrl: 'assets/images/clinic1.jpg',
      acceptsNHIMA: true, // Participates in National Health Insurance
    ),
    HealthcareFacility(
      id: '3',
      name: 'MedPlus Pharmacy',
      type: 'Pharmacy',
      address: '78 Cairo Road, Lusaka',
      distance: 0.8,
      rating: 4.5,
      services: ['Prescription Filling', 'Health Consultations', 'Medical Supplies'],
      imageUrl: 'assets/images/pharmacy1.jpg',
      acceptsNHIMA: false, // Does not participate in National Health Insurance
    ),
    HealthcareFacility(
      id: '4',
      name: 'University Teaching Hospital',
      type: 'Hospital',
      address: '10 Nationalist Road, Lusaka',
      distance: 3.7,
      rating: 4.0,
      services: ['Emergency', 'Surgery', 'Oncology', 'Cardiology', 'Neurology'],
      imageUrl: 'assets/images/hospital2.jpg',
      acceptsNHIMA: true, // Participates in National Health Insurance
    ),
  ];

  List<HealthcareFacility> get _filteredFacilities {
    if (_selectedFilter == 'All') {
      return _facilities;
    } else {
      return _facilities.where((facility) => facility.type == _selectedFilter.substring(0, _selectedFilter.length - 1)).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Facilities'),
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
                    setState(() {});
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
            child: _filteredFacilities.isEmpty
                ? const Center(
                    child: Text('No facilities found'),
                  )
                : ListView.builder(
                    itemCount: _filteredFacilities.length,
                    itemBuilder: (context, index) {
                      return _buildFacilityCard(_filteredFacilities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(HealthcareFacility facility) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Facility image/icon
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    _getFacilityIcon(facility.type),
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              // NHIMA banner
              if (facility.acceptsNHIMA)
                Positioned(
                  top: 16,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
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
                        facility.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(facility.address)),
                    const SizedBox(width: 8),
                    Text('${facility.distance} km away'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${facility.rating}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Services:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: facility.services.map((service) {
                    return Chip(
                      label: Text(
                        service,
                        style: const TextStyle(fontSize: 12),
                      ),
                      padding: const EdgeInsets.all(0),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement directions
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
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

  IconData _getFacilityIcon(String type) {
    switch (type) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Clinic':
        return Icons.medical_services;
      case 'Pharmacy':
        return Icons.medication;
      default:
        return Icons.health_and_safety;
    }
  }

  Color _getFacilityColor(String type) {
    switch (type) {
      case 'Hospital':
        return Colors.red;
      case 'Clinic':
        return Colors.blue;
      case 'Pharmacy':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class HealthcareFacility {
  final String id;
  final String name;
  final String type;
  final String address;
  final double distance;
  final double rating;
  final List<String> services;
  final String imageUrl;
  final bool acceptsNHIMA; // National Health Insurance Management Authority

  HealthcareFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.distance,
    required this.rating,
    required this.services,
    required this.imageUrl,
    this.acceptsNHIMA = false,
  });
}
