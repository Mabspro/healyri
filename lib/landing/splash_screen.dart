import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/theme.dart';
import '../shared/components.dart';
import 'onboarding_screen.dart';
import '../auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;
  
  const SplashScreen({
    Key? key,
    this.showOnboarding = true,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Navigate to next screen after delay
    Timer(const Duration(seconds: 3), () {
      if (widget.showOnboarding) {
        // If it's the first launch, show onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      } else {
        // Otherwise, go to auth wrapper which will handle authentication state
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.primaryGradient,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated app icon
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: AppComponents.logo(
                  size: 60,
                  showIcon: true,
                ),
              ),
              const SizedBox(height: 40),
              
              // App name with fade-in animation
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                  ),
                ),
                child: Text(
                  'HeaLyri',
                  style: AppTheme.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 48,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              
              // Tagline with fade-in animation
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Your Health Journey, Simplified',
                    style: AppTheme.subtitle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
