import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../landing/welcome_screen.dart';
import '../home/home_screen.dart';
import '../provider/provider_home_screen.dart';
import '../driver/driver_home_screen.dart';
import '../admin/admin_home_screen.dart';

/// AuthWrapper is a widget that handles authentication state changes
/// and redirects the user to the appropriate screen based on their auth state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // If the snapshot has user data, then they're already signed in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserRole?>(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                // Show loading indicator while getting the user role
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // For all roles, first check email verification
              return FutureBuilder<bool>(
                future: authService.isEmailVerified(),
                builder: (context, emailVerifiedSnapshot) {
                  if (emailVerifiedSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  // If email is not verified, show email verification screen
                  if (emailVerifiedSnapshot.data == false) {
                    return _buildEmailVerificationScreen(context, authService);
                  }
                  
                  // If email is verified, proceed based on role
                  if (roleSnapshot.data == UserRole.patient) {
                    return const HomeScreen();
                  } else if (roleSnapshot.data == UserRole.provider || 
                             roleSnapshot.data == UserRole.driver ||
                             roleSnapshot.data == UserRole.admin) {
                    return FutureBuilder<bool>(
                      future: authService.isUserVerified(),
                      builder: (context, verificationSnapshot) {
                        if (verificationSnapshot.connectionState == ConnectionState.waiting) {
                          // Show loading indicator while checking verification
                          return const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        // If verified, navigate to appropriate home screen
                        if (verificationSnapshot.data == true) {
                          if (roleSnapshot.data == UserRole.provider) {
                            return const ProviderHomeScreen();
                          } else if (roleSnapshot.data == UserRole.driver) {
                            return const DriverHomeScreen();
                          } else {
                            return const AdminHomeScreen();
                          }
                        } 
                        // If not verified, show verification pending screen
                        else {
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Verification Pending'),
                              actions: [
                                IconButton(
                                  icon: const Icon(Icons.logout),
                                  onPressed: () {
                                    authService.signOut();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                      (route) => false,
                                    );
                                  },
                                ),
                              ],
                            ),
                            body: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.pending_actions,
                                      size: 80,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      roleSnapshot.data == UserRole.provider
                                          ? 'Provider Verification Pending'
                                          : (roleSnapshot.data == UserRole.driver 
                                              ? 'Driver Verification Pending'
                                              : 'Admin Verification Pending'),
                                      style: Theme.of(context).textTheme.headlineSmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Your account is currently under review. '
                                      'You will be notified once your account has been verified.',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: () {
                                        authService.signOut();
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text('Sign Out'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  } 
                  // If role is not found or invalid, sign out and navigate to welcome screen
                  else {
                    authService.signOut();
                    return const WelcomeScreen();
                  }
                },
              );
            },
          );
        }
        
        // If the snapshot doesn't have data, the user is not signed in
        return const WelcomeScreen();
      },
    );
  }
  
  // Build email verification screen
  Widget _buildEmailVerificationScreen(BuildContext context, AuthService authService) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification email to ${authService.currentUser?.email}. '
                'Please check your inbox and verify your email address to continue.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Reload user to check if email is verified
                    await authService.currentUser?.reload();
                    
                    // Show loading indicator
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checking verification status...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('I\'ve Verified My Email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  try {
                    await authService.sendEmailVerification();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
