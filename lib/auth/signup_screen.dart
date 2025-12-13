import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../home/home_screen.dart';
import '../provider/provider_home_screen.dart';
import '../driver/driver_home_screen.dart';
import '../core/validators.dart';
import '../core/error_handler.dart';
import '../core/logger.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole? selectedRole;
  
  const SignUpScreen({
    Key? key,
    this.selectedRole,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late UserRole _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;
  
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    // Initialize selected role from widget if provided
    _selectedRole = widget.selectedRole ?? UserRole.patient;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.i('Starting sign up process for ${_emailController.text.trim()} with role $_selectedRole');
      
      await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        name: _nameController.text.trim(),
      );
      
      AppLogger.i('Sign up successful, navigating to home screen');
      
      if (mounted) {
        // Navigate to the appropriate home screen based on role
        _navigateToHomeScreen();
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.e('FirebaseAuthException during sign up: ${e.code} - ${e.message}', e, stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error during sign up', e, stackTrace);
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
  
  void _navigateToHomeScreen() {
    AppLogger.i('Navigating to home screen for role: $_selectedRole');
    // Navigate to the appropriate home screen based on the selected role
    if (_selectedRole == UserRole.patient) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (_selectedRole == UserRole.provider) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
        (route) => false,
      );
    } else if (_selectedRole == UserRole.driver) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
        (route) => false,
      );
    } else {
      // If role is not found, navigate to the role selection screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(24.0),
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
                    
                    const SizedBox(height: 16),
                    
                    // Logo
                    Center(
                      child: AppComponents.logo(
                        size: 60,
                        showIcon: true,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign up form
                    Container(
                      padding: const EdgeInsets.all(24),
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
                              'Create Account',
                              style: AppTheme.heading3.copyWith(
                                color: AppTheme.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Name field
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => Validators.name(value),
                            ),
                            
                            const SizedBox(height: 16),
                            
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
                            
                            // Password field with enhanced validation
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                helperText: 'Must contain uppercase, lowercase, number, and special character',
                                helperMaxLines: 2,
                              ),
                              obscureText: true,
                              validator: (value) => Validators.password(value),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Confirm password field
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) => Validators.confirmPassword(
                                value,
                                _passwordController.text,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Role selection
                            Text(
                              'I am a:',
                              style: AppTheme.subtitle.copyWith(
                                color: AppTheme.textColor,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Role selection buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildRoleButton(
                                    role: UserRole.patient,
                                    icon: Icons.person,
                                    label: 'Patient',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildRoleButton(
                                    role: UserRole.provider,
                                    icon: Icons.local_hospital,
                                    label: 'Provider',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildRoleButton(
                                    role: UserRole.driver,
                                    icon: Icons.drive_eta,
                                    label: 'Driver',
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
                            
                            // Sign up button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
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
                                  : const Text('Sign Up'),
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
                            Row(
                              children: [
                                // Google sign-up button
                                Expanded(
                                  child: _buildSocialSignInButton(
                                    onPressed: () => _signUpWithGoogle(),
                                    icon: '',
                                    label: 'Google',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black87,
                                    borderColor: Colors.grey[300]!,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Facebook sign-up button
                                Expanded(
                                  child: _buildSocialSignInButton(
                                    onPressed: () => _signUpWithFacebook(),
                                    icon: '',
                                    label: 'Facebook',
                                    backgroundColor: const Color(0xFF1877F2),
                                    textColor: Colors.white,
                                    borderColor: const Color(0xFF1877F2),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Sign in link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: AppTheme.bodyText,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignInScreen(
                                          selectedRole: _selectedRole,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: AppTheme.bodyText.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
  
  Widget _buildRoleButton({
    required UserRole role,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Sign up with Google
  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      AppLogger.i('Attempting to sign up with Google for role: $_selectedRole');
      
      await _authService.signInWithGoogle(role: _selectedRole);
      
      AppLogger.i('Google sign up successful, navigating to home screen');
      
      if (mounted) {
        _navigateToHomeScreen();
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.e('FirebaseAuthException during Google sign up: ${e.code} - ${e.message}', e, stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error during Google sign up', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(context, e, stackTrace: stackTrace, showSnackBar: false);
      }
      setState(() {
        _errorMessage = 'Google sign up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Sign up with Facebook
  Future<void> _signUpWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _authService.signInWithFacebook(role: _selectedRole);
      
      if (mounted) {
        _navigateToHomeScreen();
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.e('FirebaseAuthException during Facebook sign up: ${e.code} - ${e.message}', e, stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
      });
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error during Facebook sign up', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(context, e, stackTrace: stackTrace, showSnackBar: false);
      }
      setState(() {
        _errorMessage = 'Facebook sign up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
}
