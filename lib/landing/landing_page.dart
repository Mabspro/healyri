import 'package:flutter/material.dart';
import '../shared/constants.dart';
import '../shared/theme.dart';
import '../booking/booking_screen.dart';
import '../facility_directory/facility_directory_screen.dart';
import '../emergency/emergency_button.dart';
import '../telehealth/telehealth_screen.dart';
import '../medications/med_verification.dart';
import '../ai_triage/triage_chatbot.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildHowItWorksSection(context),
            _buildTrustIndicators(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            color: AppTheme.primaryColor,
            size: 20, // Reduced icon size
          ),
          const SizedBox(width: 4), // Reduced spacing
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Hea',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18, // Reduced font size
                  ),
                ),
                TextSpan(
                  text: 'Lyri',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.accentColor,
                    fontSize: 18, // Reduced font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Use a responsive approach for navigation items
        if (MediaQuery.of(context).size.width > 800) ...[
          TextButton(
            onPressed: () {
              // Scroll to Features section
            },
            child: const Text('Features'),
          ),
          TextButton(
            onPressed: () {
              // Scroll to How It Works section
            },
            child: const Text('How It Works'),
          ),
          TextButton(
            onPressed: () {
              // Scroll to Partners section
            },
            child: const Text('Partners'),
          ),
          TextButton(
            onPressed: () {
              // Scroll to Contact section
            },
            child: const Text('Contact'),
          ),
        ] else ...[
          // On smaller screens, show a menu button
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Show drawer or menu
            },
          ),
        ],
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            // TODO: Implement login
          },
          child: const Text(AppConstants.loginLabel),
        ),
        const SizedBox(width: 4), // Reduced spacing
        Padding(
          padding: const EdgeInsets.only(right: 8.0), // Reduced padding
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement sign up
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
            ),
            child: const Text(AppConstants.signUpLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
        vertical: AppConstants.largePadding * 1.5, // Reduced vertical padding
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appTagline,
                  style: AppTheme.heading1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Text(
                  AppConstants.appDescription,
                  style: AppTheme.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                // Added subheading as suggested
                Text(
                  "It only takes a few taps to connect with care that understands you.",
                  style: AppTheme.bodyText.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement get started
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding * 1.5, // Reduced horizontal padding
                      vertical: AppConstants.defaultPadding * 0.8, // Reduced vertical padding
                    ),
                    elevation: 4,
                  ),
                  child: const Text(AppConstants.getStartedLabel),
                ),
              ],
            ),
          ),
          // Right side image - now using the hero.png image
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/illustrations/hero.png',
                    width: 350,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      color: Colors.white, // White background for this section
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppConstants.keyFeaturesTitle,
            style: AppTheme.heading2.copyWith(
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding), // Reduced spacing
          GridView.count(
            crossAxisCount: _getFeatureGridCrossCount(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppConstants.defaultPadding,
            mainAxisSpacing: AppConstants.defaultPadding * 0.8, // Reduced spacing between rows
            childAspectRatio: 1.2, // Adjusted for more compact cards
            children: [
              _buildFeatureCard(
                context,
                Icons.calendar_today,
                AppConstants.appointmentBookingTitle,
                AppConstants.appointmentBookingDesc,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                Icons.location_on,
                AppConstants.facilityDirectoryTitle,
                AppConstants.facilityDirectoryDesc,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FacilityDirectoryScreen(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                Icons.videocam,
                AppConstants.telehealthTitle,
                AppConstants.telehealthDesc,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelehealthScreen(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                Icons.local_hospital,
                AppConstants.emergencyTitle,
                AppConstants.emergencyDesc,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyButton(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                Icons.medication,
                AppConstants.medicationsTitle,
                AppConstants.medicationsDesc,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedVerification(),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                Icons.health_and_safety,
                AppConstants.aiTriageTitle,
                AppConstants.aiTriageDesc,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TriageChatbot(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      color: Colors.grey[50], // Light gray background for this section
      child: Column(
        children: [
          Text(
            AppConstants.howItWorksTitle,
            style: AppTheme.heading2.copyWith(
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding), // Reduced spacing
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 40,
                  runSpacing: 30, // Reduced spacing
                  children: [
                    _buildStepItem(1, AppConstants.step1Title, AppConstants.step1Desc),
                    _buildStepItem(2, AppConstants.step2Title, AppConstants.step2Desc),
                    _buildStepItem(3, AppConstants.step3Title, AppConstants.step3Desc),
                    _buildStepItem(4, AppConstants.step4Title, AppConstants.step4Desc),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStepItem(1, AppConstants.step1Title, AppConstants.step1Desc),
                    const SizedBox(height: AppConstants.defaultPadding), // Reduced spacing
                    _buildStepItem(2, AppConstants.step2Title, AppConstants.step2Desc),
                    const SizedBox(height: AppConstants.defaultPadding), // Reduced spacing
                    _buildStepItem(3, AppConstants.step3Title, AppConstants.step3Desc),
                    const SizedBox(height: AppConstants.defaultPadding), // Reduced spacing
                    _buildStepItem(4, AppConstants.step4Title, AppConstants.step4Desc),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIndicators(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.defaultPadding * 1.5, // Reduced padding
        horizontal: AppConstants.largePadding,
      ),
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrustIcon(Icons.security, 'Secure'),
              const SizedBox(width: 40),
              _buildTrustIcon(Icons.privacy_tip, 'Private'),
              const SizedBox(width: 40),
              _buildTrustIcon(Icons.verified_user, 'HIPAA-aligned'),
              const SizedBox(width: 40),
              _buildTrustIcon(Icons.lock, 'Encrypted'),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding), // Reduced spacing
          Text(
            'Your data is protected and never shared without your consent.',
            style: AppTheme.subtitle.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 28, // Reduced icon size
        ),
        const SizedBox(height: 4), // Reduced spacing
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      color: AppTheme.primaryColor.withOpacity(0.05), // Very soft blue background
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hea',
                            style: AppTheme.heading4.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Lyri',
                            style: AppTheme.heading4.copyWith(
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Serving families, clinics, and communities – with dignity and data.',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Center column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFooterLink('About'),
                const SizedBox(height: 8),
                _buildFooterLink('Careers'),
                const SizedBox(height: 8),
                _buildFooterLink('Partner with Us'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink('Terms'),
                    const SizedBox(width: 16),
                    _buildFooterLink('Privacy'),
                  ],
                ),
              ],
            ),
          ),
          
          // Right column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook),
                      color: AppTheme.primaryColor,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.message),
                      color: AppTheme.primaryColor,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_camera),
                      color: AppTheme.primaryColor,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Email for updates',
                              border: InputBorder.none,
                            ),
                            style: AppTheme.bodyText,
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(29),
                            bottomRight: Radius.circular(29),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: AppTheme.bodyText.copyWith(
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        hoverColor: AppTheme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding * 0.8, // Reduced vertical padding
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28, // Reduced icon size
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: AppConstants.smallPadding * 0.8), // Reduced spacing
              Text(
                title,
                style: AppTheme.heading4.copyWith(
                  fontSize: 18, // Adjusted font size
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding * 0.8), // Reduced spacing
              Text(
                description,
                style: AppTheme.bodyText,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int step, String title, String description) {
    return SizedBox(
      width: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.accentColor,
            child: Text(
              step.toString(),
              style: AppTheme.heading2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.heading4.copyWith(
                    fontSize: 16, // Adjusted font size
                  ),
                ),
                const SizedBox(height: 4), // Reduced spacing
                Text(
                  description,
                  style: AppTheme.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getFeatureGridCrossCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 3;
    } else if (width > 800) {
      return 2;
    } else {
      return 1;
    }
  }
}
