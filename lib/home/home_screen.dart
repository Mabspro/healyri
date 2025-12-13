import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import '../shared/shimmer.dart';
import '../booking/booking_screen.dart' hide Appointment, AppointmentStatus;
import '../facility_directory/facility_directory_screen.dart';
import '../emergency/emergency_screen.dart';
import '../telehealth/telehealth_screen.dart';
import '../medications/med_verification.dart';
import '../ai_triage/triage_chatbot.dart';
import '../profile/profile_screen.dart';
import '../services/appointment_service.dart';
import '../services/health_vitals_service.dart';
import '../services/auth_service.dart';
import '../models/appointment.dart';
import '../landing/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Find, 2 = Chat, 3 = Profile
  final TextEditingController _searchController = TextEditingController();
  
  // Services
  final AppointmentService _appointmentService = AppointmentService();
  final HealthVitalsService _healthVitalsService = HealthVitalsService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Find',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chat',
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
        return _buildHomeTab();
      case 1:
        return _buildFindTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }
  
  Widget _buildHomeTab() {
    final isMobile = Responsive.isMobile(context);
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
            
            // Health status card
            _buildHealthStatusCard(),
            const SizedBox(height: 24),
            
            // Quick actions
            AppComponents.sectionHeader(
              title: 'Quick Actions',
              actionText: 'See All',
              onActionPressed: () {
                // Navigate to all features
              },
            ),
            GridView.count(
              crossAxisCount: Responsive.gridColumnCount(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20),
              crossAxisSpacing: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20),
              childAspectRatio: isMobile ? 1.4 : 1.5,
              children: [
                AppComponents.quickActionCard(
                  title: 'Book Appointment',
                  icon: Icons.calendar_today_rounded,
                  onTap: () => context.pushSlide(const BookingScreen()),
                  gradientColors: AppTheme.primaryGradient,
                ),
                AppComponents.quickActionCard(
                  title: 'Find Doctor',
                  icon: Icons.search_rounded,
                  onTap: () => context.pushSlide(const FacilityDirectoryScreen()),
                  gradientColors: AppTheme.secondaryGradient,
                ),
                AppComponents.quickActionCard(
                  title: 'Medication',
                  icon: Icons.medication_rounded,
                  onTap: () => context.pushSlide(const MedVerification()),
                  gradientColors: AppTheme.accentGradient,
                ),
                AppComponents.quickActionCard(
                  title: 'Emergency',
                  icon: Icons.emergency_rounded,
                  onTap: () => context.pushSlide(const EmergencyScreen()),
                  isEmergency: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Upcoming appointment
            AppComponents.sectionHeader(
              title: 'Upcoming Appointment',
              actionText: 'View All',
              onActionPressed: () {
                // Navigate to appointments list
              },
            ),
            _buildUpcomingAppointment(),
            
            const SizedBox(height: 24),
            
            // Health tips
            AppComponents.sectionHeader(
              title: 'Health Tips',
              actionText: 'More',
              onActionPressed: () {
                // Navigate to health tips
              },
            ),
            _buildHealthTipCard(),
            
            const SizedBox(height: 24),
            
            // Telehealth services
            AppComponents.sectionHeader(
              title: 'Telehealth Services',
              actionText: 'View All',
              onActionPressed: () => context.pushSlide(const TelehealthScreen()),
            ),
            _buildTelehealthCard(),
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

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String displayName = 'User';
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          displayName = data?['name'] as String? ?? 
                       user.displayName ?? 
                       'User';
        } else if (user.displayName != null) {
          displayName = user.displayName!;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                      'Good morning,',
                      style: AppTheme.caption,
                    ),
                    Text(
                      displayName,
                      style: AppTheme.heading3,
                    ),
                  ],
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
      },
    );
  }
  
  Widget _buildHealthStatusCard() {
    return StreamBuilder<HealthVitals>(
      stream: _healthVitalsService.streamLatestVitals(),
      builder: (context, snapshot) {
        final vitals = snapshot.data ?? HealthVitals();
        
        // Format values with fallback to "--"
        final heartRate = vitals.heartRate != null 
            ? '${vitals.heartRate} bpm' 
            : '--';
        final steps = vitals.steps != null 
            ? _formatNumber(vitals.steps!)
            : '--';
        final sleep = vitals.sleepHours != null 
            ? '${vitals.sleepHours!.toStringAsFixed(1)} hrs' 
            : '--';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppTheme.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.primaryShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Health Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthMetric('Heart Rate', heartRate, Icons.favorite),
                  _buildHealthMetric('Steps', steps, Icons.directions_walk),
                  _buildHealthMetric('Sleep', sleep, Icons.nightlight_round),
                ],
              ),
              const SizedBox(height: 16),
              AppComponents.gradientButton(
                text: 'View Health Report',
                onPressed: () {
                  // Navigate to health report
                },
                gradientColors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.3)],
                icon: Icons.arrow_forward_rounded,
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHealthMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildUpcomingAppointment() {
    return StreamBuilder<Appointment?>(
      stream: _appointmentService.streamUpcomingAppointment(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerCard(
            height: 120,
            borderRadius: 16,
          );
        }

        final appointment = snapshot.data;

        if (appointment == null) {
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
                  'No upcoming appointments',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingScreen(),
                      ),
                    );
                  },
                  child: const Text('Book an Appointment'),
                ),
              ],
            ),
          );
        }

        return AppComponents.appointmentCard(
          doctorName: appointment.providerName ?? 'TBD',
          specialty: appointment.serviceType ?? 'General Consultation',
          facilityName: appointment.facilityName,
          dateTime: appointment.dateTime,
          status: appointment.status == AppointmentStatus.confirmed 
              ? 'Confirmed' 
              : appointment.status == AppointmentStatus.pending
                  ? 'Pending'
                  : 'Scheduled',
          onTap: () {
            // Navigate to appointment details
          },
        );
      },
    );
  }
  
  Widget _buildHealthTipCard() {
    return AppComponents.enhancedCard(
      accentGradient: AppTheme.accentGradient,
      onTap: () {
        // Navigate to health tip details
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Staying Hydrated',
                  style: AppTheme.heading4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Drinking enough water is crucial for maintaining good health, especially during hot weather. Aim for at least 8 glasses per day.',
            style: AppTheme.bodyText,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to health tip details
                },
                child: Row(
                  children: [
                    Text(
                      'Read More',
                      style: AppTheme.subtitle.copyWith(
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTelehealthCard() {
    return AppComponents.enhancedCard(
      accentGradient: AppTheme.secondaryGradient,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TelehealthScreen(),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: AppTheme.secondaryColor,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Talk to a Doctor Now',
                  style: AppTheme.heading4,
                ),
                const SizedBox(height: 8),
                Text(
                  'Get medical advice from the comfort of your home',
                  style: AppTheme.bodyText,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '5 Doctors Available',
                            style: AppTheme.caption.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
  
  Widget _buildFindTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Care',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 16),
            AppComponents.searchField(
              controller: _searchController,
              hintText: 'Search for doctors, facilities, or services',
              onVoiceSearch: () {
                // Implement voice search
              },
            ),
            const SizedBox(height: 24),
            
            // Categories
            AppComponents.sectionHeader(
              title: 'Categories',
              actionText: 'See All',
              onActionPressed: () {
                // Navigate to all categories
              },
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryCard('General', Icons.medical_services_rounded),
                  _buildCategoryCard('Pediatrics', Icons.child_care_rounded),
                  _buildCategoryCard('Cardiology', Icons.favorite_rounded),
                  _buildCategoryCard('Dermatology', Icons.face_rounded),
                  _buildCategoryCard('Orthopedics', Icons.accessibility_new_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Nearby facilities
            AppComponents.sectionHeader(
              title: 'Nearby Facilities',
              actionText: 'View Map',
              onActionPressed: () {
                // Navigate to map view
              },
            ),
            _buildNearbyFacilityCard(
              'Lusaka Medical Center',
              '2.5 km away',
              '4.8',
              'General Hospital',
            ),
            const SizedBox(height: 16),
            _buildNearbyFacilityCard(
              'University Teaching Hospital',
              '3.7 km away',
              '4.6',
              'Specialized Care',
            ),
            const SizedBox(height: 16),
            _buildNearbyFacilityCard(
              'Kanyama Clinic',
              '1.2 km away',
              '4.2',
              'Primary Care',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryCard(String title, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.bodyText.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNearbyFacilityCard(
    String name,
    String distance,
    String rating,
    String type,
  ) {
    return AppComponents.enhancedCard(
      onTap: () {
        // Navigate to facility details
      },
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.heading4,
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.textSecondaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: AppTheme.bodyText,
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
  
  Widget _buildChatTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_rounded,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI Health Assistant',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Get answers to your health questions and receive guidance on what to do next.',
              style: AppTheme.bodyText,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AppComponents.gradientButton(
              text: 'Start Chat',
              onPressed: () => context.pushSlide(const TriageChatbot()),
              icon: Icons.chat_rounded,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileTab() {
    // This is a placeholder. In a real app, you would implement a proper profile screen
    // or navigate to the ProfileScreen.
    return const ProfileScreen();
  }

  /// Format number with comma separators (e.g., 8243 -> "8,243")
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
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
                String displayName = 'User';
                String email = '';
                
                if (user != null) {
                  email = user.email ?? '';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    displayName = data?['name'] as String? ?? 
                                 user.displayName ?? 
                                 'User';
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
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    selected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 0;
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
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Appointments'),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushSlide(const BookingScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: const Text('Find Facilities'),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushSlide(const FacilityDirectoryScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings screen
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      // Show about dialog
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
                      context.pushAndRemoveUntilSlide(const WelcomeScreen());
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
