import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () {
        _showEmergencyOptions(context);
      },
      child: const Icon(
        Icons.emergency,
        color: Colors.white,
      ),
    );
  }

  void _showEmergencyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Emergency Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildEmergencyOption(
                context,
                'Call Emergency Services',
                Icons.call,
                Colors.red,
                () {
                  Navigator.pop(context);
                  _showEmergencyCallDialog(context);
                },
              ),
              const SizedBox(height: 16),
              _buildEmergencyOption(
                context,
                'Find Nearest Hospital',
                Icons.local_hospital,
                Colors.blue,
                () {
                  Navigator.pop(context);
                  _showNearestHospitalDialog(context);
                },
              ),
              const SizedBox(height: 16),
              _buildEmergencyOption(
                context,
                'First Aid Guide',
                Icons.healing,
                Colors.green,
                () {
                  Navigator.pop(context);
                  _showFirstAidGuide(context);
                },
              ),
              const SizedBox(height: 16),
              _buildEmergencyOption(
                context,
                'Contact Emergency Contact',
                Icons.contact_phone,
                Colors.orange,
                () {
                  Navigator.pop(context);
                  _showEmergencyContactDialog(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Call Emergency Services'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmergencyContact('Ambulance', '991', Icons.local_hospital),
              const SizedBox(height: 8),
              _buildEmergencyContact('Police', '999', Icons.local_police),
              const SizedBox(height: 8),
              _buildEmergencyContact('Fire', '993', Icons.fire_truck),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmergencyContact(String title, String number, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      subtitle: Text(number),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () {
          // TODO: Implement call functionality
        },
      ),
    );
  }

  void _showNearestHospitalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nearest Hospitals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNearbyHospital(
                'Lusaka General Hospital',
                '2.5 km away',
                '123 Independence Ave, Lusaka',
              ),
              const SizedBox(height: 8),
              _buildNearbyHospital(
                'University Teaching Hospital',
                '3.7 km away',
                '10 Nationalist Road, Lusaka',
              ),
              const SizedBox(height: 8),
              _buildNearbyHospital(
                'Kanyama Clinic',
                '1.2 km away',
                '45 Kanyama Road, Lusaka',
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
                // TODO: Implement directions to nearest hospital
              },
              child: const Text('Get Directions'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNearbyHospital(String name, String distance, String address) {
    return ListTile(
      leading: const Icon(Icons.local_hospital, color: Colors.blue),
      title: Text(name),
      subtitle: Text(address),
      trailing: Text(
        distance,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showFirstAidGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('First Aid Guide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFirstAidItem('CPR', Icons.favorite),
              _buildFirstAidItem('Choking', Icons.air),
              _buildFirstAidItem('Bleeding', Icons.bloodtype),
              _buildFirstAidItem('Burns', Icons.whatshot),
              _buildFirstAidItem('Fractures', Icons.healing),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFirstAidItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // TODO: Implement first aid guide details
      },
    );
  }

  void _showEmergencyContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Emergency Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmergencyContactPerson(
                'John Doe',
                'Spouse',
                '+260 97 1234567',
              ),
              const SizedBox(height: 8),
              _buildEmergencyContactPerson(
                'Jane Smith',
                'Doctor',
                '+260 96 7654321',
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
                // TODO: Implement add emergency contact
              },
              child: const Text('Add Contact'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmergencyContactPerson(
      String name, String relation, String phone) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(name),
      subtitle: Text('$relation • $phone'),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () {
          // TODO: Implement call functionality
        },
      ),
    );
  }
}
