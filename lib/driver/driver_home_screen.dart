import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import '../services/driver_service.dart';
import '../services/auth_service.dart';
import '../models/emergency.dart';
import 'emergency_trip_screen.dart';
import '../landing/welcome_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = false;
  final DriverService _driverService = DriverService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    final driverId = await _driverService.getCurrentUserDriverId();
    setState(() {
      _driverId = driverId;
    });
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
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Earnings',
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
        return _buildHistoryTab();
      case 2:
        return _buildEarningsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildDashboardTab();
    }
  }
  
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Online status bar
          _buildOnlineStatusBar(),
          
          Padding(
            padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar with profile
                _buildAppBar(),
                const SizedBox(height: 24),
                
                // Stats overview
                _buildStatsOverview(),
                const SizedBox(height: 24),
                
                // Current/Pending trips
                AppComponents.sectionHeader(
                  title: 'Assigned Emergencies',
                ),
                _driverId != null
                  ? _buildAssignedEmergenciesList()
                  : _buildNoTripsMessage('Loading...'),
                
                const SizedBox(height: 24),
                
                // Map view
                AppComponents.sectionHeader(
                  title: 'Your Area',
                  actionText: 'Full Map',
                  onActionPressed: () {
                    // Navigate to full map
                  },
                ),
                _buildMapPreview(),
                
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOnlineStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: _isOnline ? AppTheme.successColor : Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isOnline ? Icons.circle : Icons.circle_outlined,
                color: _isOnline ? Colors.white : Colors.grey[700],
                size: 12,
              ),
              const SizedBox(width: 8),
              Text(
                _isOnline ? 'You are online' : 'You are offline',
                style: AppTheme.subtitle.copyWith(
                  color: _isOnline ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: AppTheme.successColor.withOpacity(0.5),
          ),
        ],
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
              builder: (context, snapshot) {
                String displayName = 'Driver';
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  displayName = data?['name'] as String? ?? 
                               user.displayName ?? 
                               'Driver';
                } else if (user.displayName != null) {
                  displayName = user.displayName!;
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
                      ],
                    ),
                  ],
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
    if (_driverId == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 30), (_) => _)
                .asyncMap((_) => _driverService.getTodayCompletedTripsCount(_driverId!)),
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
                            Icons.directions_car_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trips',
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
                      'Completed Today',
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
          child: StreamBuilder<double>(
            stream: Stream.periodic(const Duration(seconds: 30), (_) => _)
                .asyncMap((_) => _driverService.getTodayEarnings(_driverId!)),
            builder: (context, snapshot) {
              final earnings = snapshot.data ?? 0.0;
              return AppComponents.enhancedCard(
                accentGradient: AppTheme.accentGradient,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Earnings',
                          style: AppTheme.subtitle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'K${earnings.toStringAsFixed(2)}',
                      style: AppTheme.heading2,
                    ),
                    Text(
                      'Today',
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
  
  Widget _buildAssignedEmergenciesList() {
    if (_driverId == null) {
      return _buildNoTripsMessage('Loading...');
    }

    return StreamBuilder<List<Emergency>>(
      stream: _driverService.getAssignedEmergencies(_driverId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildNoTripsMessage('Error loading emergencies');
        }

        final emergencies = snapshot.data ?? [];

        if (emergencies.isEmpty) {
          return _buildNoTripsMessage('No assigned emergencies');
        }

        return Column(
          children: emergencies.map((emergency) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEmergencyItem(emergency),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmergencyItem(Emergency emergency) {
    final statusText = emergency.status.toString().split('.').last;
    final statusColor = _getStatusColor(emergency.status);

    return InkWell(
      onTap: () {
        context.pushSlide(EmergencyTripScreen(emergency: emergency));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_hospital,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency #${emergency.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emergency.urgency.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getUrgencyColor(emergency.urgency),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.dispatched:
        return Colors.orange;
      case EmergencyStatus.inTransit:
        return Colors.purple;
      case EmergencyStatus.arrived:
        return Colors.teal;
      default:
        return Colors.grey;
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
  
  Widget _buildNoTripsMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.subtitle.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Map Preview',
              style: AppTheme.subtitle.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: AppComponents.quickActionCard(
            title: 'Navigation',
            icon: Icons.navigation_rounded,
            onTap: () {
              // Open navigation
            },
            gradientColors: AppTheme.primaryGradient,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppComponents.quickActionCard(
            title: 'Support',
            icon: Icons.headset_mic_rounded,
            onTap: () {
              // Open support
            },
            gradientColors: AppTheme.secondaryGradient,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHistoryTab() {
    // Placeholder for the History tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Trip History',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'View your past trips',
            style: AppTheme.bodyText,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarningsTab() {
    // Placeholder for the Earnings tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Earnings',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'View your earnings and payment history',
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
            'Driver Profile',
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
                String displayName = 'Driver';
                String email = '';
                
                if (user != null) {
                  email = user.email ?? '';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    displayName = data?['name'] as String? ?? 
                                 user.displayName ?? 
                                 'Driver';
                  } else if (user.displayName != null) {
                    displayName = user.displayName!;
                  }
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
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
                    leading: const Icon(Icons.history),
                    title: const Text('History'),
                    selected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('Earnings'),
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
