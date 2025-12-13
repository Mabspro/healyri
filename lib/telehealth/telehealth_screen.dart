import 'package:flutter/material.dart';

class TelehealthScreen extends StatefulWidget {
  const TelehealthScreen({Key? key}) : super(key: key);

  @override
  State<TelehealthScreen> createState() => _TelehealthScreenState();
}

class _TelehealthScreenState extends State<TelehealthScreen> {
  final List<TelehealthProvider> _providers = [
    TelehealthProvider(
      id: '1',
      name: 'Dr. Mulenga',
      specialty: 'General Practitioner',
      experience: 10,
      rating: 4.8,
      availability: 'Available Today',
      imageUrl: 'assets/images/doctor1.jpg',
      isVolunteer: true,
    ),
    TelehealthProvider(
      id: '2',
      name: 'Dr. Banda',
      specialty: 'Pediatrician',
      experience: 15,
      rating: 4.9,
      availability: 'Available Tomorrow',
      imageUrl: 'assets/images/doctor2.jpg',
      isVolunteer: false,
    ),
    TelehealthProvider(
      id: '3',
      name: 'Dr. Phiri',
      specialty: 'Dermatologist',
      experience: 8,
      rating: 4.7,
      availability: 'Available Today',
      imageUrl: 'assets/images/doctor3.jpg',
      isVolunteer: true,
    ),
    TelehealthProvider(
      id: '4',
      name: 'Dr. Zulu',
      specialty: 'Cardiologist',
      experience: 20,
      rating: 4.9,
      availability: 'Available in 2 Days',
      imageUrl: 'assets/images/doctor4.jpg',
      isVolunteer: false,
    ),
  ];

  final List<String> _specialties = [
    'All Specialties',
    'General Practice',
    'Pediatrics',
    'Dermatology',
    'Cardiology',
    'Gynecology',
    'Psychiatry',
    'Orthopedics',
  ];

  String _selectedSpecialty = 'All Specialties';
  bool _showVolunteersOnly = false;

  List<TelehealthProvider> get _filteredProviders {
    return _providers.where((provider) {
      if (_showVolunteersOnly && !provider.isVolunteer) {
        return false;
      }
      if (_selectedSpecialty != 'All Specialties' &&
          provider.specialty != _selectedSpecialty) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Telehealth'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Find Provider'),
              Tab(text: 'My Consultations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFindProviderTab(),
            _buildMyConsultationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFindProviderTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find a Telehealth Provider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSpecialty,
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem<String>(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSpecialty = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _showVolunteersOnly,
                    onChanged: (value) {
                      setState(() {
                        _showVolunteersOnly = value ?? false;
                      });
                    },
                  ),
                  const Text('Show volunteer providers only'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredProviders.isEmpty
              ? const Center(
                  child: Text('No providers found'),
                )
              : ListView.builder(
                  itemCount: _filteredProviders.length,
                  itemBuilder: (context, index) {
                    return _buildProviderCard(_filteredProviders[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(TelehealthProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (provider.isVolunteer)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Volunteer',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.specialty,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.experience} years experience',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.availability,
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.isVolunteer ? 'Free Consultation' : 'K150 / 30 min',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: provider.isVolunteer ? Colors.green : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Available for video call',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _showBookConsultationDialog(context, provider);
                  },
                  child: const Text('Book Consultation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyConsultationsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Upcoming Consultations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book a consultation with a healthcare provider',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              DefaultTabController.of(context).animateTo(0);
            },
            child: const Text('Find a Provider'),
          ),
        ],
      ),
    );
  }

  void _showBookConsultationDialog(
      BuildContext context, TelehealthProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Book Consultation with ${provider.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specialty: ${provider.specialty}'),
              const SizedBox(height: 8),
              Text(
                  'Fee: ${provider.isVolunteer ? 'Free (Volunteer)' : 'K150 / 30 min'}'),
              const SizedBox(height: 16),
              const Text(
                'Select Date and Time:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Date'),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available Time Slots:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTimeSlot('9:00 AM'),
                  _buildTimeSlot('10:00 AM'),
                  _buildTimeSlot('11:30 AM'),
                  _buildTimeSlot('2:00 PM'),
                  _buildTimeSlot('3:30 PM'),
                  _buildTimeSlot('5:00 PM'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason for Consultation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Briefly describe your symptoms or concerns',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showBookingConfirmation(context);
              },
              child: const Text('Book Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeSlot(String time) {
    return ChoiceChip(
      label: Text(time),
      selected: false,
      onSelected: (selected) {
        // TODO: Implement time slot selection
      },
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Consultation Booked'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Your telehealth consultation has been booked successfully!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'You will receive a notification with the link to join the video call.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class TelehealthProvider {
  final String id;
  final String name;
  final String specialty;
  final int experience;
  final double rating;
  final String availability;
  final String imageUrl;
  final bool isVolunteer;

  TelehealthProvider({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.availability,
    required this.imageUrl,
    required this.isVolunteer,
  });
}
