import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import '../services/appointment_service.dart';
import '../services/facility_service.dart';
import '../services/auth_service.dart';
import '../models/appointment.dart';
import 'emergency_dashboard_screen.dart';
import '../landing/welcome_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // Services
  final AppointmentService _appointmentService = AppointmentService();
  final FacilityService _facilityService = FacilityService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _facilityId;
  
  @override
  void initState() {
    super.initState();
    _loadFacilityId();
  }

  Future<void> _loadFacilityId() async {
    try {
      final facilityId = await _facilityService.getCurrentUserFacilityId();
      setState(() {
        _facilityId = facilityId;
      });
    } catch (e) {
      // Handle error silently - facilityId will remain null
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
      drawer: _buildDrawer(),
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildScheduleTab();
      case 2:
        return _buildPatientsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildDashboardTab();
    }
  }
  
  Widget _buildDashboardTab() {
    final horizontalPadding = Responsive.horizontalPadding(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar with profile
            _buildAppBar(),
            const SizedBox(height: 24),
            
            // Stats overview
            _buildStatsOverview(),
            const SizedBox(height: 24),
            
            // Today's appointments
            AppComponents.sectionHeader(
              title: 'Today\'s Appointments',
              actionText: 'View All',
              onActionPressed: () {
                // Navigate to appointments list
              },
            ),
            _buildAppointmentsList(),
            
            const SizedBox(height: 24),
            
            // Quick actions
            AppComponents.sectionHeader(
              title: 'Quick Actions',
              actionText: 'More',
              onActionPressed: () {
                // Navigate to all actions
              },
            ),
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // Recent patients
            AppComponents.sectionHeader(
              title: 'Recent Patients',
              actionText: 'View All',
              onActionPressed: () {
                // Navigate to patients list
              },
            ),
            _buildRecentPatients(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    final user = _auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(user.uid).snapshots(),
              builder: (context, userSnapshot) {
                String displayName = 'Provider';
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final data = userSnapshot.data!.data() as Map<String, dynamic>?;
                  displayName = data?['name'] as String? ?? 
                               user.displayName ?? 
                               'Provider';
                } else if (user.displayName != null) {
                  displayName = user.displayName!;
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: _facilityId != null
                      ? _firestore.collection('facilities').doc(_facilityId).snapshots()
                      : null,
                  builder: (context, facilitySnapshot) {
                    String facilityName = 'No Facility';
                    if (facilitySnapshot.hasData && facilitySnapshot.data!.exists) {
                      final data = facilitySnapshot.data!.data() as Map<String, dynamic>?;
                      facilityName = data?['name'] as String? ?? 'No Facility';
                    }

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          backgroundImage: user.photoURL != null 
                              ? NetworkImage(user.photoURL!) 
                              : null,
                          child: user.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTheme.caption,
                            ),
                            Text(
                              displayName,
                              style: AppTheme.heading3,
                            ),
                            Text(
                              facilityName,
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Show notifications
              },
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 30), (_) => _)
                .asyncMap((_) => _appointmentService.getTodayAppointmentsCount(
                      facilityId: _facilityId,
                      providerId: _auth.currentUser?.uid,
                    )),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return AppComponents.enhancedCard(
                accentGradient: AppTheme.primaryGradient,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Today',
                          style: AppTheme.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$count',
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Appointments',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 30), (_) => _)
                .asyncMap((_) => _appointmentService.getPendingAppointmentsCount(
                      facilityId: _facilityId,
                      providerId: _auth.currentUser?.uid,
                    )),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return AppComponents.enhancedCard(
                accentGradient: AppTheme.secondaryGradient,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.pending_actions_rounded,
                            color: AppTheme.secondaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pending',
                          style: AppTheme.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$count',
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Appointments',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppointmentsList() {
    if (_facilityId == null && _auth.currentUser == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Loading...'),
        ),
      );
    }

    return StreamBuilder<List<Appointment>>(
      stream: _appointmentService.streamTodayAppointments(
        facilityId: _facilityId,
        providerId: _auth.currentUser?.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No appointments today',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: appointments.take(3).map((appointment) {
            final time = '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';
            return Column(
              children: [
                _buildAppointmentItem(
                  appointment.patientName ?? 'Patient',
                  appointment.serviceType ?? 'Consultation',
                  time,
                  appointment.status == AppointmentStatus.confirmed 
                      ? 'Confirmed' 
                      : 'Pending',
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        );
      },
    );
  }
  
  Widget _buildAppointmentItem(
    String patientName,
    String purpose,
    String time,
    String status,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppTheme.successColor;
        break;
      case 'pending':
        statusColor = AppTheme.warningColor;
        break;
      case 'cancelled':
        statusColor = AppTheme.errorColor;
        break;
      default:
        statusColor = AppTheme.infoColor;
    }
    
    return AppComponents.enhancedCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        // Navigate to appointment details
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: AppTheme.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  purpose,
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: AppTheme.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: AppTheme.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppComponents.quickActionCard(
                title: 'Emergency Dashboard',
                icon: Icons.emergency_rounded,
                onTap: () {
                  context.pushSlide(const EmergencyDashboardScreen());
                },
                gradientColors: const [
                  Color(0xFFFF0000),
                  Color(0xFFFF4444),
                ],
                isEmergency: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppComponents.quickActionCard(
                title: 'Start Telehealth',
                icon: Icons.videocam_rounded,
                onTap: () {
                  // Navigate to telehealth
                },
                gradientColors: AppTheme.primaryGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppComponents.quickActionCard(
                title: 'Add Patient',
                icon: Icons.person_add_rounded,
                onTap: () {
                  // Navigate to add patient
                },
                gradientColors: AppTheme.secondaryGradient,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppComponents.quickActionCard(
                title: 'Schedule',
                icon: Icons.calendar_today_rounded,
                onTap: () {
                  // Navigate to schedule
                },
                gradientColors: AppTheme.accentGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRecentPatients() {
    return Column(
      children: [
        _buildPatientItem(
          'Sarah Johnson',
          'Last visit: 2 days ago',
          'General Checkup',
        ),
        const SizedBox(height: 12),
        _buildPatientItem(
          'Michael Banda',
          'Last visit: 1 week ago',
          'Follow-up',
        ),
        const SizedBox(height: 12),
        _buildPatientItem(
          'Esther Phiri',
          'Last visit: 2 weeks ago',
          'Consultation',
        ),
      ],
    );
  }
  
  Widget _buildPatientItem(
    String patientName,
    String lastVisit,
    String reason,
  ) {
    return AppComponents.enhancedCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        // Navigate to patient details
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: AppTheme.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastVisit,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: AppTheme.bodyText,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onPressed: () {
              // Navigate to patient details
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildScheduleTab() {
    // Placeholder for the Schedule tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Schedule',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage your appointments',
            style: AppTheme.bodyText,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPatientsTab() {
    // Placeholder for the Patients tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Patients',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage your patients',
            style: AppTheme.bodyText,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab() {
    // Placeholder for the Profile tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Provider Profile',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage your profile',
            style: AppTheme.bodyText,
          ),
        ],
      ),
    );
  }

  /// Build the drawer menu
  Widget _buildDrawer() {
    final user = _auth.currentUser;
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header with user info
            StreamBuilder<DocumentSnapshot>(
              stream: user != null 
                  ? _firestore.collection('users').doc(user.uid).snapshots()
                  : null,
              builder: (context, snapshot) {
                String displayName = 'Provider';
                String email = '';
                
                if (user != null) {
                  email = user.email ?? '';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    displayName = data?['name'] as String? ?? 
                                 user.displayName ?? 
                                 'Provider';
                  } else if (user.displayName != null) {
                    displayName = user.displayName!;
                  }
                }

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  accountName: Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                            size: 40,
                          )
                        : null,
                  ),
                );
              },
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    selected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Schedule'),
                    selected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Patients'),
                    selected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    selected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emergency),
                    title: const Text('Emergency Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushSlide(const EmergencyDashboardScreen());
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help screen
                    },
                  ),
                ],
              ),
            ),
            
            // Sign out button at bottom
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                // Show confirmation dialog
                final shouldSignOut = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (shouldSignOut == true && mounted) {
                  try {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error signing out: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
