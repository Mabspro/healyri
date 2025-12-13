import 'package:flutter/material.dart';
import '../shared/theme.dart';
import '../shared/components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock data for demonstration
  final String _userName = "Sarah Johnson";
  final String _email = "sarah.johnson@example.com";
  final String _phoneNumber = "+260 97 1234567";
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Profile',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 24),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileOptions(),
            const SizedBox(height: 24),
            _buildHealthInformation(),
            const SizedBox(height: 24),
            _buildAccountOptions(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            _email,
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _phoneNumber,
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          AppComponents.outlinedButton(
            text: 'Edit Profile',
            onPressed: () {
              // Navigate to edit profile
            },
            icon: Icons.edit,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileOptions() {
    return AppComponents.enhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTheme.heading4,
          ),
          const SizedBox(height: 16),
          _buildProfileOption(
            'Medical History',
            Icons.history,
            () {
              // Navigate to medical history
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Allergies & Conditions',
            Icons.warning_amber_rounded,
            () {
              // Navigate to allergies and conditions
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Medications',
            Icons.medication_rounded,
            () {
              // Navigate to medications
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Emergency Contacts',
            Icons.emergency_rounded,
            () {
              // Navigate to emergency contacts
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthInformation() {
    return AppComponents.enhancedCard(
      accentGradient: AppTheme.accentGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Information',
            style: AppTheme.heading4,
          ),
          const SizedBox(height: 16),
          _buildProfileOption(
            'Health Records',
            Icons.folder_rounded,
            () {
              // Navigate to health records
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Test Results',
            Icons.analytics_rounded,
            () {
              // Navigate to test results
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Prescriptions',
            Icons.receipt_long_rounded,
            () {
              // Navigate to prescriptions
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Appointments',
            Icons.calendar_today_rounded,
            () {
              // Navigate to appointments
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountOptions() {
    return AppComponents.enhancedCard(
      accentGradient: AppTheme.secondaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: AppTheme.heading4,
          ),
          const SizedBox(height: 16),
          _buildProfileOption(
            'Notifications',
            Icons.notifications_rounded,
            () {
              // Navigate to notifications settings
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Privacy & Security',
            Icons.security_rounded,
            () {
              // Navigate to privacy and security settings
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Language',
            Icons.language_rounded,
            () {
              // Navigate to language settings
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Help & Support',
            Icons.help_rounded,
            () {
              // Navigate to help and support
            },
          ),
          const Divider(),
          _buildProfileOption(
            'Logout',
            Icons.logout_rounded,
            () {
              // Logout
            },
            textColor: AppTheme.errorColor,
            iconColor: AppTheme.errorColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyText.copyWith(
                  color: textColor ?? AppTheme.textColor,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
