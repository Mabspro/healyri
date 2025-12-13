import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../shared/theme.dart';
import '../shared/components.dart';
import '../shared/route_transitions.dart';
import '../shared/responsive.dart';
import 'role_selection_screen.dart';

// Wave painter for the background
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // First wave
    path.moveTo(0, size.height * 0.7);
    
    // Create a very subtle wave pattern
    for (int i = 0; i < size.width.toInt(); i++) {
      path.lineTo(
        i.toDouble(), 
        size.height * 0.7 + math.sin(i * 0.01) * 10 // Reduced amplitude
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Second wave (slightly different)
    final path2 = Path();
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    path2.moveTo(0, size.height * 0.8);
    
    for (int i = 0; i < size.width.toInt(); i++) {
      path2.lineTo(
        i.toDouble(), 
        size.height * 0.8 + math.cos(i * 0.015) * 8 // Reduced amplitude
      );
    }
    
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  // For info cards carousel
  int _currentCardIndex = 0;
  final PageController _cardPageController = PageController();
  
  // Info card data
  final List<Map<String, dynamic>> _infoCards = [
    {
      'title': 'Connect with Healthcare',
      'description': 'Find and connect with healthcare providers in your area, with ratings and reviews.',
      'icon': Icons.local_hospital,
    },
    {
      'title': 'Book Appointments',
      'description': 'Schedule appointments with your preferred providers at times that work for you.',
      'icon': Icons.calendar_today,
    },
    {
      'title': 'Telehealth Consultations',
      'description': 'Connect with healthcare providers remotely through video calls from home.',
      'icon': Icons.video_call,
    },
    {
      'title': 'Emergency Transport',
      'description': 'Quick access to emergency services and transportation when you need it most.',
      'icon': Icons.local_taxi,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 1.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
    ));
    
    // Start animation
    _animationController.forward();
    
    // Set up pulsing animation for the button (slower)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        try {
          // Slow down the animation by setting a longer duration
          _animationController.duration = const Duration(milliseconds: 3000);
          _animationController.repeat(reverse: true);
        } catch (e) {
          // Ignore errors if controller is disposed
        }
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
      body: Stack(
        children: [
          // Background gradient with subtle wave pattern
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.primaryGradient,
              ),
            ),
            child: CustomPaint(
              painter: WavePainter(),
              size: Size.infinite,
            ),
          ),
          
          // Content with top padding
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = Responsive.isMobile(context);
                final horizontalPadding = Responsive.horizontalPadding(context);
                
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: isMobile ? 16.0 : 32.0,
                          left: horizontalPadding,
                          right: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            // Top section with logo and tagline
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16.0 : 32.0,
                                vertical: isMobile ? 16.0 : 32.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Animated logo
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 32.0),
                                        child: AppComponents.logo(
                                          size: isMobile ? 64 : 80, // Responsive logo
                                          showIcon: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Hero tagline
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Your health journey. Empowered.',
                                            style: AppTheme.heading2.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 24 : 32,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: isMobile ? 12 : 16),
                                          Text(
                                            'Book, manage, and stay on top of your care – anytime, anywhere.',
                                            style: AppTheme.subtitle.copyWith(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: isMobile ? 16 : 18,
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Info cards carousel (Fixed height instead of Expanded)
                            SizedBox(
                              height: isMobile ? 280 : 350,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 12.0 : 24.0,
                                ),
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildInfoCardsCarousel(isMobile: isMobile),
                                ),
                              ),
                            ),

                            // Spacer to push button to bottom if space exists
                            const Spacer(),
                            
                            // Get Started button with pulsing animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 20.0 : 32.0,
                                  vertical: isMobile ? 16.0 : 24.0,
                                ),
                                child: ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: GestureDetector(
                                    onTap: () => _navigateToRoleSelection(context),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isMobile ? 16 : 20,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(40), // Pill shape
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Get Started',
                                        style: AppTheme.buttonText.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontSize: isMobile ? 16 : 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Create a new screen for role selection
  void _navigateToRoleSelection(BuildContext context) {
    context.pushSlide(const RoleSelectionScreen(), direction: SlideDirection.right);
  }
  
  // Build the info cards carousel
  Widget _buildInfoCardsCarousel({bool isMobile = true}) {
    return Stack(
      children: [
        // PageView for the cards
        PageView.builder(
          controller: _cardPageController,
          itemCount: _infoCards.length,
          onPageChanged: (index) {
            setState(() {
              _currentCardIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final card = _infoCards[index];
            return _buildInfoCard(
              title: card['title'],
              description: card['description'],
              icon: card['icon'],
              isMobile: isMobile,
            );
          },
        ),
        
        // Left navigation button
        if (_currentCardIndex > 0)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _cardPageController.previousPage(
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
        
        // Right navigation button
        if (_currentCardIndex < _infoCards.length - 1)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _cardPageController.nextPage(
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
          
        // Page indicator dots
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _infoCards.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentCardIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentCardIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build a single info card
  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    bool isMobile = true,
  }) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 32.0,
        ),
        padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isMobile ? 40 : 48,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              title,
              style: AppTheme.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              description,
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
