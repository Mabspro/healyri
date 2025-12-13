import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      facilityName: 'Lusaka General Hospital',
      doctorName: 'Dr. Mulenga',
      specialty: 'General Practitioner',
      date: DateTime.now().add(const Duration(days: 2)),
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: '2',
      facilityName: 'Kanyama Clinic',
      doctorName: 'Dr. Banda',
      specialty: 'Pediatrician',
      date: DateTime.now().add(const Duration(days: 5)),
      status: AppointmentStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingAppointments(),
            _buildPastAppointments(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showBookAppointmentModal(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return _appointments.isEmpty
        ? const Center(
            child: Text('No upcoming appointments'),
          )
        : ListView.builder(
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              return _buildAppointmentCard(_appointments[index]);
            },
          );
  }

  Widget _buildPastAppointments() {
    return const Center(
      child: Text('No past appointments'),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.facilityName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(appointment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Doctor: ${appointment.doctorName}'),
            Text('Specialty: ${appointment.specialty}'),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(appointment.date)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Time: ${_formatTime(appointment.date)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement reschedule
                  },
                  child: const Text('Reschedule'),
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
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color;
    String text;

    switch (status) {
      case AppointmentStatus.confirmed:
        color = Colors.green;
        text = 'Confirmed';
        break;
      case AppointmentStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case AppointmentStatus.completed:
        color = Colors.blue;
        text = 'Completed';
        break;
    }

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showBookAppointmentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book New Appointment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Select Facility',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Select Department/Specialty',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Select Doctor (Optional)',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Select Time',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Reason for Visit',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement booking logic
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Book Appointment'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

enum AppointmentStatus {
  confirmed,
  pending,
  cancelled,
  completed,
}

class Appointment {
  final String id;
  final String facilityName;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.facilityName,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.status,
  });
}
