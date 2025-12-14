import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import '../booking/booking_screen.dart' hide Appointment, AppointmentStatus;
import '../facility_directory/facility_directory_screen.dart';
import '../emergency/emergency_screen.dart';
import '../emergency/emergency_commitment_view.dart';
import '../models/emergency.dart';
import '../services/emergency_service.dart';
import '../shared/emergency_components.dart';
import '../profile/profile_screen.dart';
import '../services/auth_service.dart';
import '../landing/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 0 = Home, 1 = Find, 2 = Chat, 3 = Profile
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFAB = false; // Show FAB only when scrolled down
  
  // Services
  final EmergencyService _emergencyService = EmergencyService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // Show FAB when scrolled past emergency banner (approximately 200px)
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow != _showFAB) {
      setState(() {
        _showFAB = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      floatingActionButton: _showFAB && _currentIndex == 0 ? _buildEmergencyFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            icon: Icon(Icons.local_hospital_rounded),
            label: 'Facilities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_rounded),
            label: 'Coverage',
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
  
  Widget _buildEmergencyFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.pushSlide(const EmergencyScreen()),
      backgroundColor: Colors.red[700],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.emergency, size: 28),
      label: const Text(
        'Emergency',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 6,
    );
  }
  
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildFacilitiesTab();
      case 2:
        return _buildCoverageTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }
  
  Widget _buildHomeTab() {
    final horizontalPadding = Responsive.horizontalPadding(context);
    
    return StreamBuilder<List<Emergency>>(
      stream: _emergencyService.getUserEmergencies(),
      builder: (context, snapshot) {
        // Get active emergency (not resolved or cancelled)
        final emergencies = snapshot.data ?? [];
        final activeEmergency = emergencies.firstWhere(
          (e) => e.status != EmergencyStatus.resolved && 
                 e.status != EmergencyStatus.cancelled,
          orElse: () => emergencies.isNotEmpty ? emergencies.first : Emergency(
            id: '',
            patientId: '',
            timestamp: DateTime.now(),
            location: const GeoPoint(0, 0),
            urgency: EmergencyUrgency.medium,
          ),
        );
        
        final hasActiveEmergency = emergencies.isNotEmpty && 
                                   activeEmergency.status != EmergencyStatus.resolved &&
                                   activeEmergency.status != EmergencyStatus.cancelled;
        
        return SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar with profile
                _buildAppBar(),
                const SizedBox(height: 24),
                
                // EMERGENCY DOMINANT SECTION (Top Priority)
                if (hasActiveEmergency)
                  _buildActiveEmergencyBanner(activeEmergency)
                else
                  _buildEmergencyHelpBanner(),
                
                const SizedBox(height: 24),
                
                // Nearby Facilities (Secondary - supports emergency wedge)
                AppComponents.sectionHeader(
                  title: 'Nearby Facilities',
                  actionText: 'View All',
                  onActionPressed: () => context.pushSlide(const FacilityDirectoryScreen()),
                ),
                _buildNearbyFacilitiesList(),
                
                const SizedBox(height: 24),
                
                // Emergency Readiness (Replaces appointments - emergency-first focus)
                AppComponents.sectionHeader(
                  title: 'Emergency Readiness',
                  actionText: 'Review Setup',
                  onActionPressed: () {
                    // TODO: Navigate to emergency setup/review screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emergency setup review coming soon')),
                    );
                  },
                ),
                _buildEmergencyReadiness(),
                
                const SizedBox(height: 24),
                
                // My Coverage (Subscription status)
                _buildCoverageCard(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActiveEmergencyBanner(Emergency emergency) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyCommitmentView(emergency: emergency),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[700]!, Colors.red[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Emergency',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      EmergencyStatusChip(
                        status: emergency.status,
                        urgency: emergency.urgency,
                        compact: true,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to view status and updates',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.red[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Urgent Help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Emergency response coordination',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.pushSlide(const EmergencyScreen()),
            icon: const Icon(Icons.emergency, size: 20),
            label: const Text(
              'Request Emergency Help',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNearbyFacilitiesList() {
    // TODO: Fetch real nearby facilities from Firestore
    return Column(
      children: [
        _buildFacilityCard('Lusaka Medical Center', '2.5 km', 'General Hospital'),
        const SizedBox(height: 12),
        _buildFacilityCard('University Teaching Hospital', '3.7 km', 'Specialized Care'),
        const SizedBox(height: 12),
        _buildFacilityCard('Kanyama Clinic', '1.2 km', 'Primary Care'),
      ],
    );
  }
  
  Widget _buildFacilityCard(String name, String distance, String type) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_hospital, color: Colors.blue[700], size: 24),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(type),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  distance,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () => context.pushSlide(const FacilityDirectoryScreen()),
      ),
    );
  }
  
  Widget _buildCoverageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to coverage details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coverage details coming soon')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Colors.blue[700], size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'My Coverage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Active Coverage',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Emergency services available 24/7',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: View plan
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Plan'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Add family member
                    },
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Add Family'),
                  ),
                ],
              ),
            ],
          ),
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
  
  
  Widget _buildEmergencyReadiness() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Emergency Readiness',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Readiness checklist
            _buildReadinessItem(
              Icons.check_circle,
              'Coverage active',
              Colors.green,
              true,
            ),
            const SizedBox(height: 12),
            _buildReadinessItem(
              Icons.location_on,
              'Location enabled',
              Colors.green,
              true,
            ),
            const SizedBox(height: 12),
            _buildReadinessItem(
              Icons.phone,
              'Hotline available',
              Colors.green,
              true,
            ),
            const SizedBox(height: 12),
            _buildReadinessItem(
              Icons.contacts,
              'Emergency contacts set',
              Colors.orange,
              false, // TODO: Check if emergency contacts are set
            ),
            
            const SizedBox(height: 20),
            
            // Battery optimization tip (optional)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.battery_charging_full, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep phone charged for faster emergency response',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // CTA Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to emergency setup/review screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emergency setup review coming soon')),
                );
              },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Review Emergency Setup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReadinessItem(IconData icon, String label, Color color, bool isComplete) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isComplete ? color : Colors.grey[400],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isComplete ? Colors.grey[900] : Colors.grey[600],
            ),
          ),
        ),
        if (!isComplete)
          Text(
            'Set up',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
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
              'Facilities',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Find verified healthcare facilities near you',
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
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
            
            // Navigate to full facility directory
            ElevatedButton.icon(
              onPressed: () {
                context.pushSlide(const FacilityDirectoryScreen());
              },
              icon: const Icon(Icons.local_hospital_rounded),
              label: const Text('View All Facilities'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick access to nearby facilities
            AppComponents.sectionHeader(
              title: 'Nearby Facilities',
              actionText: 'View Map',
              onActionPressed: () {
                context.pushSlide(const FacilityDirectoryScreen());
              },
            ),
            // TODO: Replace with real FacilityService.getNearbyFacilities()
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Loading facilities...'),
              ),
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
  
  Widget _buildCoverageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coverage & Readiness',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Your emergency protection and setup status',
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Coming Soon Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'These features are being developed and will be available soon.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Telehealth (Coming Soon)
          _buildComingSoonCard(
            'Telehealth Services',
            'Talk to a doctor from home',
            Icons.videocam_rounded,
            Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // AI Triage (Coming Soon)
          _buildComingSoonCard(
            'AI Health Assistant',
            'Get answers to health questions',
            Icons.chat_rounded,
            Colors.purple,
          ),
          
          const SizedBox(height: 16),
          
          // Medication Verification (Coming Soon)
          _buildComingSoonCard(
            'Medication Verification',
            'Verify medication authenticity',
            Icons.medication_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }
  
  Widget _buildComingSoonCard(String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: 0.6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileTab() {
    // This is a placeholder. In a real app, you would implement a proper profile screen
    // or navigate to the ProfileScreen.
    return const ProfileScreen();
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
                  // Appointments moved to Explore tab (Coming Soon)
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
