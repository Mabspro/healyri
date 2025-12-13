import 'package:flutter/material.dart';
import '../shared/theme.dart';
import '../shared/components.dart';
import '../auth/auth_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Define the intro slides
  final List<IntroSlide> _slides = [
    IntroSlide(
      title: 'Welcome to HeaLyri',
      description: 'Your health journey, simplified. Connect with healthcare providers, book appointments, and manage your health in one place.',
      image: 'assets/images/illustrations/hero.png',
    ),
    IntroSlide(
      title: 'Find Care Nearby',
      description: 'Discover healthcare facilities and providers in your area, with ratings and reviews from other patients.',
      image: 'assets/images/illustrations/hero.png',
    ),
    IntroSlide(
      title: 'Telehealth Consultations',
      description: 'Connect with healthcare providers remotely through video calls, from the comfort of your home.',
      image: 'assets/images/illustrations/hero.png',
    ),
    IntroSlide(
      title: 'Emergency Transport',
      description: 'Quick access to emergency services and transportation to nearby facilities when you need it most.',
      image: 'assets/images/illustrations/hero.png',
    ),
  ];

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
            child: Column(
              children: [
                // Logo at the top with new monogram design
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Center(
                    child: AppComponents.logo(
                      size: 48,
                      showIcon: true,
                    ),
                  ),
                ),
                
                // Intro carousel with navigation buttons
                Expanded(
                  child: Stack(
                    children: [
                      // Carousel
                      AppComponents.introCarousel(
                        slides: _slides,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        currentPage: _currentPage,
                        pageController: _pageController,
                        onGetStarted: () => _navigateToAuthWrapper(context),
                        getStartedText: 'Get Started',
                      ),
                      
                      // Left navigation button (previous)
                      if (_currentPage > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Right navigation button (next)
                      if (_currentPage < _slides.length - 1)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
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
  
  void _navigateToAuthWrapper(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthWrapper(),
      ),
    );
  }
}
