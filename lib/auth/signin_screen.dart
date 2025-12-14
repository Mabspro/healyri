import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import '../home/home_screen.dart';
import '../provider/provider_home_screen.dart';
import '../driver/driver_home_screen.dart';
import '../admin/admin_home_screen.dart';
import '../core/logger.dart';
import '../core/error_handler.dart';
import '../core/validators.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  final UserRole selectedRole;
  
  const SignInScreen({
    Key? key,
    required this.selectedRole,
  }) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  
  final AuthService _authService = AuthService();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.i('Attempting to sign in with email: ${_emailController.text.trim()}');
      
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        rememberMe: _rememberMe,
      );
      
      AppLogger.i('Sign in successful, navigating to home screen');
      
      if (mounted) {
        // Navigate to the appropriate home screen based on role
        _navigateToHomeScreen(fallbackRole: widget.selectedRole);
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.e('FirebaseAuthException during sign in: ${e.code} - ${e.message}', e, stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error during sign in', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(context, e, stackTrace: stackTrace, showSnackBar: false);
      }
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.i('Attempting to sign in with Google for role: ${widget.selectedRole}');
      
      await _authService.signInWithGoogle(role: widget.selectedRole);
      
      AppLogger.i('Google sign in successful, navigating to home screen');
      
      if (mounted) {
        _navigateToHomeScreen(fallbackRole: widget.selectedRole);
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.e('FirebaseAuthException during Google sign in: ${e.code} - ${e.message}', e, stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error during Google sign in', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(context, e, stackTrace: stackTrace, showSnackBar: false);
      }
      setState(() {
        _errorMessage = 'Google sign in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Sign in with Facebook
  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _authService.signInWithFacebook(role: widget.selectedRole);
      
      if (mounted) {
        _navigateToHomeScreen(fallbackRole: widget.selectedRole);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Facebook sign in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  String _getErrorMessage(String code) {
    AppLogger.d('Getting error message for code: $code');
    return ErrorHandler.getErrorMessage(FirebaseAuthException(code: code));
  }
  
  void _navigateToHomeScreen({UserRole? fallbackRole}) async {
    AppLogger.i('Navigating to home screen. Fallback role: $fallbackRole');
    
    try {
      // Get the user's role from Firestore
      UserRole? userRole;
      try {
        userRole = await _authService.getUserRole();
      } catch (e) {
        AppLogger.w('Failed to get user role from Firestore: $e');
      }
      
      // Use fallback role if provided and Firestore lookup failed or returned null
      if (userRole == null && fallbackRole != null) {
        AppLogger.i('Using fallback role: $fallbackRole');
        userRole = fallbackRole;
      }
      
      AppLogger.d('User role retrieved: $userRole');
      
      if (!mounted) return;
      
      // Navigate to the appropriate home screen based on role
      if (userRole == UserRole.patient) {
        AppLogger.i('Navigating to patient home screen');
        context.pushAndRemoveUntilSlide(const HomeScreen());
      } else if (userRole == UserRole.provider) {
        AppLogger.i('Navigating to provider home screen');
        context.pushAndRemoveUntilSlide(const ProviderHomeScreen());
      } else if (userRole == UserRole.driver) {
        AppLogger.i('Navigating to driver home screen');
        context.pushAndRemoveUntilSlide(const DriverHomeScreen());
      } else if (userRole == UserRole.admin) {
        AppLogger.i('Navigating to admin home screen');
        context.pushAndRemoveUntilSlide(const AdminHomeScreen());
      } else {
        AppLogger.w('No valid role found, returning to role selection');
        // If role is not found, navigate to the role selection screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error during navigation', e, stackTrace);
      // If there's an error, show a message and return to the sign-in screen
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          stackTrace: stackTrace,
          userMessage: 'Error retrieving user role. Please try again.',
        );
      }
    }
  }
  
  // Show forgot password dialog
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;
    String? successMessage;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  if (successMessage != null)
                    Text(
                      successMessage!,
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Validate email
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            setState(() {
                              errorMessage = 'Please enter your email address';
                              successMessage = null;
                            });
                            return;
                          }
                          
                          // Show loading indicator
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                            successMessage = null;
                          });
                          
                          try {
                            // Send password reset email
                            await _authService.resetPassword(email);
                            
                            // Show success message
                            setState(() {
                              isLoading = false;
                              successMessage = 'Password reset email sent to $email';
                              errorMessage = null;
                            });
                            
                            // Close dialog after a delay
                            Future.delayed(const Duration(seconds: 2), () {
                              if (!mounted) return;
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            });
                          } catch (e) {
                            // Show error message
                            setState(() {
                              isLoading = false;
                              errorMessage = 'Failed to send password reset email. Please try again.';
                              successMessage = null;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Reset Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Build a social sign-in button
  Widget _buildSocialSignInButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use proper icons for social sign-in
          if (label == 'Google')
            // Google logo - using a simple 'G' icon for now
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Icon(
              Icons.facebook,
              color: textColor,
              size: 24,
            ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

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
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    
                    SizedBox(height: isMobile ? 12 : 16),
                    
                    // Logo
                    Center(
                      child: AppComponents.logo(
                        size: isMobile ? 56 : 64,
                        showIcon: true,
                      ),
                    ),
                    
                    SizedBox(height: isMobile ? 24 : 32),
                    
                    // Sign in form
                    Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome Back',
                              style: AppTheme.heading3.copyWith(
                                color: AppTheme.textColor,
                                fontSize: isMobile ? 20 : 22,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Text(
                              'Emergency services are available 24/7 once signed in.',
                              style: AppTheme.caption.copyWith(
                                color: Colors.grey[600],
                                fontSize: isMobile ? 11 : 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: isMobile ? 20 : 24),
                            
                            // Email field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => Validators.email(value),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) => Validators.required(value, 'Password'),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Remember me and Forgot password row
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Remember me checkbox
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppTheme.primaryColor,
                                    ),
                                    Text(
                                      'Remember Me',
                                      style: AppTheme.bodyText.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Forgot password link
                                GestureDetector(
                                  onTap: () {
                                    _showForgotPasswordDialog(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppTheme.bodyText.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Error message
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _errorMessage!,
                                  style: AppTheme.bodyText.copyWith(
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            // Sign in button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Sign In'),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // OR divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Social sign-in buttons
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                // Google sign-in button
                                SizedBox(
                                  width: 150, // Fixed width for consistent look
                                  child: _buildSocialSignInButton(
                                    onPressed: () => _signInWithGoogle(),
                                    icon: 'assets/images/icons/google_logo.png',
                                    label: 'Google',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black87,
                                    borderColor: Colors.grey[300]!,
                                  ),
                                ),
                                // Facebook sign-in button
                                SizedBox(
                                  width: 150, 
                                  child: _buildSocialSignInButton(
                                    onPressed: () => _signInWithFacebook(),
                                    icon: 'assets/images/icons/facebook_logo.png',
                                    label: 'Facebook',
                                    backgroundColor: const Color(0xFF1877F2),
                                    textColor: Colors.white,
                                    borderColor: const Color(0xFF1877F2),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Sign up link
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: AppTheme.bodyText,
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.pushSlide(
                                            SignUpScreen(
                                              selectedRole: widget.selectedRole,
                                            ),
                                            direction: SlideDirection.right,
                                          );
                                        },
                                        child: Text(
                                          'Sign Up',
                                          style: AppTheme.bodyText.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
