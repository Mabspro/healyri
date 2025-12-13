import 'package:flutter/material.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import '../services/auth_service.dart';
import '../auth/signin_screen.dart';
import '../auth/signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = Responsive.horizontalPadding(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.primaryGradient,
              ),
            ),
          ),
          
          // Content - Mobile-first design with aggressive optimization
          SafeArea(
            child: Column(
              children: [
                // Top section with back button and logo - Very compact on mobile
                Container(
                  height: isMobile ? 90 : 160,
                  child: Stack(
                    children: [
                      // Back button - Positioned absolutely
                      Positioned(
                        left: isMobile ? 4.0 : 16.0,
                        top: isMobile ? 0.0 : 8.0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: isMobile ? 22 : 28,
                        ),
                      ),
                      // Logo - Centered
                      Center(
                        child: AppComponents.logo(
                          size: isMobile ? 44 : 72,
                          showIcon: true,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Sign in options - Scrollable with proper constraints
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: isMobile ? 8 : 20,
                            bottom: isMobile ? 8 : 16,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - (isMobile ? 16 : 36),
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Sign in to access your care tools',
                                    style: AppTheme.heading3.copyWith(
                                      color: AppTheme.textColor,
                                      fontSize: isMobile ? 15 : 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isMobile ? 10 : 20),
                                  _buildSignInOption(
                                    context,
                                    'Patient',
                                    Icons.person,
                                    AppTheme.primaryGradient,
                                    isMobile ? 'Appointments & health data' : 'Manage appointments and health data',
                                    () => _navigateToPatientHome(context),
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 6 : 12),
                                  _buildSignInOption(
                                    context,
                                    'Healthcare Provider',
                                    Icons.local_hospital,
                                    AppTheme.secondaryGradient,
                                    isMobile ? 'Schedules & consults' : 'Manage schedules and consults',
                                    () => _navigateToClinicHome(context),
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 6 : 12),
                                  _buildSignInOption(
                                    context,
                                    'Driver',
                                    Icons.drive_eta,
                                    AppTheme.accentGradient,
                                    isMobile ? 'Patient transport' : 'Handle patient transport services',
                                    () => _navigateToDriverHome(context),
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 6 : 12),
                                  _buildSignInOption(
                                    context,
                                    'System Admin',
                                    Icons.admin_panel_settings,
                                    const [Color(0xFF607D8B), Color(0xFF455A64)],
                                    isMobile ? 'Platform settings' : 'Manage platform settings and users',
                                    () => _navigateToAdminHome(context),
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 10 : 16),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: isMobile ? 0 : 8),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Text(
                                          'Don\'t have an account? ',
                                          style: AppTheme.bodyText.copyWith(
                                            fontSize: isMobile ? 12 : 16,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            context.pushSlide(
                                              const SignUpScreen(),
                                              direction: SlideDirection.right,
                                            );
                                          },
                                          child: Text(
                                            'Sign Up',
                                            style: AppTheme.bodyText.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 12 : 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSignInOption(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    String description,
    VoidCallback onTap, {
    bool isMobile = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 14,
          ),
          constraints: BoxConstraints(
            minHeight: isMobile ? 48 : 60,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: isMobile ? 18 : 24,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Flexible(
                    child: Text(
                      title,
                      style: AppTheme.buttonText.copyWith(
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: isMobile ? 2 : 6),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 0),
                  child: Text(
                    description,
                    style: AppTheme.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 8 : 12,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToPatientHome(BuildContext context) {
    // Navigate to sign in screen with patient role
    context.pushSlide(
      const SignInScreen(selectedRole: UserRole.patient),
      direction: SlideDirection.right,
    );
  }
  
  void _navigateToClinicHome(BuildContext context) {
    // Navigate to sign in screen with provider role
    context.pushSlide(
      const SignInScreen(selectedRole: UserRole.provider),
      direction: SlideDirection.right,
    );
  }
  
  void _navigateToDriverHome(BuildContext context) {
    // Navigate to sign in screen with driver role
    context.pushSlide(
      const SignInScreen(selectedRole: UserRole.driver),
      direction: SlideDirection.right,
    );
  }

  void _navigateToAdminHome(BuildContext context) {
    // Navigate to sign in screen with admin role
    context.pushSlide(
      const SignInScreen(selectedRole: UserRole.admin),
      direction: SlideDirection.right,
    );
  }
}
