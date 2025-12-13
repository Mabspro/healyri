# HeaLyri UI/UX Enhancement Plan

This document outlines a comprehensive plan to enhance HeaLyri's user interface and experience, focusing on creating a more appealing, aesthetically pleasing, and marketable mobile application. The recommendations are based on a thorough review of the current implementation and industry best practices.

## Current State Analysis

The current HeaLyri application has a solid foundation with:

- A consistent color scheme with primary blue and accent green
- Standard Material Design components
- Functional layouts for key features
- Basic responsive design

However, to elevate the app to a premium, market-ready state, several enhancements are needed to create a more engaging, distinctive, and user-friendly experience.

## Enhancement Goals

1. **Create a distinctive visual identity** that stands out in the healthcare app market
2. **Improve user engagement** through modern UI patterns and micro-interactions
3. **Enhance usability** for the target demographics, including users with varying tech literacy
4. **Optimize for mobile-first experience** rather than a web-like interface
5. **Implement role-specific interfaces** for patients and drivers (Yango-style)
6. **Increase visual appeal** through modern design techniques and visual elements

## Design System Enhancements

### Color Palette Refinement

The current color palette is functional but could be more distinctive and emotionally resonant:

**Current:**
- Primary Blue (#3566A8)
- Secondary Color (#4C84D1)
- Accent Color (#0EB686)

**Recommended:**
- Primary Blue: Shift to a more vibrant, trustworthy blue (#1A73E8)
- Secondary Color: A complementary purple for contrast (#6C63FF)
- Accent Color: A warmer, more energetic teal (#00BFA5)
- Add a soft gradient system for backgrounds and cards:
  - Primary Gradient: #1A73E8 → #5393FF
  - Secondary Gradient: #6C63FF → #8F88FF
  - Accent Gradient: #00BFA5 → #4CDFBC

### Typography Enhancement

**Current:**
- Google Fonts Open Sans for all text elements
- Standard size hierarchy

**Recommended:**
- Primary Font: Switch to Montserrat for headings (more distinctive and modern)
- Secondary Font: Keep Open Sans for body text (excellent readability)
- Increase contrast between heading and body text sizes
- Implement a more refined typographic scale:
  - H1: 32sp (was 28sp)
  - H2: 26sp (was 24sp)
  - H3: 22sp (was 20sp)
  - H4: 18sp (unchanged)
  - Body: 16sp (was 14sp)
  - Caption: 14sp (was 12sp)

### Component Redesign

#### Buttons

**Current:**
- Standard Material buttons with rounded corners
- Basic hover and press states

**Recommended:**
- Implement a custom button design with:
  - Subtle elevation and shadows
  - Animated press effects (scale down slightly)
  - Gradient backgrounds for primary actions
  - Animated loading states
  - Haptic feedback on press

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 4,
    shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
  ).copyWith(
    backgroundColor: MaterialStateProperty.all(
      LinearGradient(
        colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    ),
  ),
  child: Text('Get Started', style: AppTheme.buttonText),
)
```

#### Cards

**Current:**
- Standard Material cards with minimal styling
- Basic elevation and rounded corners

**Recommended:**
- Implement a more distinctive card design:
  - Subtle inner shadows
  - Gradient borders or accents
  - Animated hover/tap states
  - Category-specific visual indicators
  - Asymmetric layouts for visual interest

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        spreadRadius: 0,
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            height: 6,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: cardContent,
        ),
      ],
    ),
  ),
)
```

#### Input Fields

**Current:**
- Standard Material text fields
- Basic outline borders

**Recommended:**
- Create more engaging input fields:
  - Animated label transitions
  - Contextual input validation with visual feedback
  - Custom focus effects
  - Integrated clear/search buttons
  - Voice input option for accessibility

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  decoration: BoxDecoration(
    color: _isFocused ? Colors.white : Colors.grey[50],
    borderRadius: BorderRadius.circular(16),
    boxShadow: _isFocused
        ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ]
        : null,
  ),
  child: TextField(
    decoration: InputDecoration(
      hintText: 'Search for healthcare providers',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: IconButton(
        icon: const Icon(Icons.mic),
        onPressed: () {
          // Voice input functionality
        },
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _isFocused
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
    ),
  ),
)
```

### Visual Elements

**Current:**
- Limited use of illustrations and icons
- Standard Material icons

**Recommended:**
- Custom illustration system:
  - Create a cohesive set of medical-themed illustrations
  - Implement animated illustrations for key screens
  - Use illustrations to communicate complex health concepts
- Enhanced iconography:
  - Custom icon set with medical theme
  - Animated icons for interactive elements
  - Consistent style across all icons

## Screen-Specific Enhancements

### Landing Page

**Current:**
- Website-like layout with hero section and feature cards
- Standard navigation and footer

**Recommended:**
- Reimagine as a true mobile app home screen:
  - Welcome card with personalized greeting
  - Quick action buttons for common tasks
  - Recent activity or upcoming appointments
  - Health status summary
  - Contextual recommendations

```dart
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar with profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning,', style: AppTheme.caption),
                        Text('Sarah', style: AppTheme.heading3),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Health status card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Health Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHealthMetric('Heart Rate', '72 bpm', Icons.favorite),
                      _buildHealthMetric('Steps', '8,243', Icons.directions_walk),
                      _buildHealthMetric('Sleep', '7.5 hrs', Icons.nightlight_round),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick actions
            const Text('Quick Actions', style: AppTheme.heading3),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard('Book Appointment', Icons.calendar_today),
                _buildQuickActionCard('Find Doctor', Icons.search),
                _buildQuickActionCard('Medication', Icons.medication),
                _buildQuickActionCard('Emergency', Icons.emergency, isEmergency: true),
              ],
            ),
            const SizedBox(height: 24),
            
            // Upcoming appointment
            const Text('Upcoming Appointment', style: AppTheme.heading3),
            const SizedBox(height: 16),
            _buildAppointmentCard(),
            
            const SizedBox(height: 24),
            
            // Health tips
            const Text('Health Tips', style: AppTheme.heading3),
            const SizedBox(height: 16),
            _buildHealthTipCard(),
          ],
        ),
      ),
    ),
  ),
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    currentIndex: 0,
    type: BottomNavigationBarType.fixed,
  ),
)
```

### Medication Verification

**Current:**
- Functional but basic UI with standard form elements
- Limited visual feedback for verification results

**Recommended:**
- Create a more engaging and intuitive verification flow:
  - Camera viewfinder with AR overlay for barcode scanning
  - Animated transitions between scanning and results
  - Visual storytelling for the verification process
  - Rich result cards with clear visual indicators
  - Interactive 3D medication viewer (for verified medications)

```dart
// Barcode scanner with AR overlay
Container(
  height: 300,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Theme.of(context).primaryColor.withOpacity(0.5),
      width: 2,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: Stack(
      children: [
        // Camera preview would go here
        Container(color: Colors.black),
        
        // Scanning overlay
        Center(
          child: Container(
            width: 250,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // Scanning animation
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1500),
            width: 250,
            height: 2,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            margin: EdgeInsets.only(
              top: _scanLinePosition,
            ),
          ),
        ),
        
        // Instructions overlay
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Position barcode within the frame',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
)
```

### Telehealth Screen

**Current:**
- Basic list of providers with standard cards
- Simple booking dialog

**Recommended:**
- Create a more engaging telehealth experience:
  - Rich provider cards with video intro thumbnails
  - Availability calendar with visual time slot selection
  - Pre-consultation checklist and preparation guide
  - Waiting room experience with estimated wait time
  - Post-consultation summary and follow-up scheduling

```dart
// Provider card with video preview
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    children: [
      // Video preview section
      Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/images/doctor_office.jpg',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                radius: 24,
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '0:45',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Provider info
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/doctor1.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Mulenga',
                        style: AppTheme.heading4,
                      ),
                      Text(
                        'General Practitioner',
                        style: AppTheme.caption.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 8,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Available Now',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip('10+ years', Icons.work),
                const SizedBox(width: 8),
                _buildInfoChip('4.8 (120)', Icons.star),
                const SizedBox(width: 8),
                _buildInfoChip('English, Bemba', Icons.language),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam),
                    label: const Text('Consult'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### AI Triage Chatbot

**Current:**
- Basic chat interface with message bubbles
- Limited visual differentiation for different message types

**Recommended:**
- Create a more engaging and helpful chat experience:
  - Rich message types (text, options, images, videos)
  - Animated typing indicators
  - Visual symptom selection interface
  - Body map for symptom location selection
  - Severity scales with visual indicators
  - Contextual quick replies
  - Voice input with visual feedback

```dart
// Symptom selection interface
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'What symptoms are you experiencing?',
        style: AppTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildSymptomChip('Headache', isSelected: true),
          _buildSymptomChip('Fever'),
          _buildSymptomChip('Cough'),
          _buildSymptomChip('Sore Throat'),
          _buildSymptomChip('Fatigue'),
          _buildSymptomChip('Nausea'),
          _buildSymptomChip('Dizziness'),
          _buildSymptomChip('Rash'),
          _buildSymptomChip('Other...'),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        'Where is your headache located?',
        style: AppTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/head_outline.png',
              height: 200,
            ),
            // Tap areas would be positioned here
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Rate the pain intensity:',
        style: AppTheme.subtitle.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: Theme.of(context).primaryColor,
          inactiveTrackColor: Colors.grey[300],
          thumbColor: Theme.of(context).primaryColor,
          trackHeight: 8,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        ),
        child: Slider(
          value: 7,
          min: 1,
          max: 10,
          divisions: 9,
          label: '7',
          onChanged: (value) {},
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Mild', style: AppTheme.caption),
          Text('Moderate', style: AppTheme.caption),
          Text('Severe', style: AppTheme.caption),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Submit'),
        ),
      ),
    ],
  ),
)
```

### Emergency Button

**Current:**
- Basic implementation with standard buttons

**Recommended:**
- Create a more accessible and effective emergency interface:
  - Prominent, easy-to-access emergency button
  - Clear visual hierarchy for emergency options
  - One-tap emergency service calling
  - Location sharing with emergency services
  - Emergency contact notification system
  - Quick access to medical ID information

```dart
// Emergency button with expanding options
GestureDetector(
  onTap: () {
    setState(() {
      _isEmergencyExpanded = !_isEmergencyExpanded;
    });
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: _isEmergencyExpanded ? MediaQuery.of(context).size.width - 32 : 80,
    height: _isEmergencyExpanded ? 200 : 80,
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(_isEmergencyExpanded ? 24 : 40),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    ),
    child: _isEmergencyExpanded
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emergency,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Emergency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEmergencyExpanded = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildEmergencyOption(
                        'Call Emergency',
                        Icons.call,
                        () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildEmergencyOption(
                        'Find Hospital',
                        Icons.local_hospital,
                        () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildEmergencyOption(
                  'Share Location with Emergency Contacts',
                  Icons.share_location,
                  () {},
                  isFullWidth: true,
                ),
              ],
            ),
          )
        : const Center(
            child: Icon(
              Icons.emergency,
              color: Colors.white,
              size: 40,
            ),
          ),
  ),
)
```

### Yango-Style Driver Interface

**Current:**
- Not yet implemented

**Recommended:**
- Create a dedicated driver interface focused on:
  - Map-centric UI with current location and requests
  - Clear request cards with patient info and destination
  - One-tap accept/reject functionality
  - Turn-by-turn navigation integration
  - Earnings tracking and history
  - Status toggle (online/offline)
  - Emergency support features

```dart
// Driver home screen with map
Scaffold(
  body: Stack(
    children: [
      // Map would be here
      Container(color: Colors.grey[300]),
      
      // Status bar
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/driver_profile.jpg'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe', style: AppTheme.subtitle),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: AppTheme.caption.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
      
      // Request card
      Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Transport',
                          style: AppTheme.subtitle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '3.2 km away',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'K120',
                      style: AppTheme.heading3.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup: 123 Chilenje South Rd',
                            style: AppTheme.bodyText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dropoff: University Teaching Hospital',
                            style: AppTheme.bodyText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
)
```

## Implementation Plan

To transform HeaLyri's UI/UX from its current state to the enhanced vision outlined above, we recommend the following phased approach:

### Phase 1: Design System Overhaul (2 Weeks)

1. **Update Theme Configuration**
   - Implement new color palette
   - Configure typography with Montserrat and Open Sans
   - Create gradient definitions
   - Define shadow styles

2. **Create Component Library**
   - Design and implement enhanced buttons
   - Design and implement card variations
   - Design and implement custom input fields
   - Create animation utilities for micro-interactions

3. **Develop Visual Assets**
   - Design custom icon set
   - Create medical-themed illustrations
   - Prepare animation assets

### Phase 2: Core Screen Redesign (3 Weeks)

1. **Landing Page Transformation**
   - Implement new mobile-first home screen
   - Create personalized welcome experience
   - Develop quick action grid
   - Design upcoming appointment cards

2. **Navigation Redesign**
   - Implement enhanced bottom navigation
   - Create smooth screen transitions
   - Design navigation hierarchy

3. **Profile & Settings**
   - Design user profile experience
   - Create settings interface
   - Implement theme switching capability

### Phase 3: Feature-Specific Enhancements (4 Weeks)

1. **Medication Verification Enhancement**
   - Implement AR-enabled barcode scanner
   - Create animated verification process
   - Design rich result cards

2. **Telehealth Experience**
   - Develop enhanced provider cards with video previews
   - Create visual time slot selection
   - Design waiting room experience
   - Implement post-consultation summary

3. **AI Triage Chatbot**
   - Design rich message types
   - Implement visual symptom selection
   - Create body map interface
   - Develop severity scale visualization

4. **Emergency Features**
   - Implement expanding emergency button
   - Create one-tap emergency calling
   - Design location sharing interface
   - Develop emergency contact system

### Phase 4: Driver Interface Development (3 Weeks)

1. **Map Integration**
   - Implement map-centric interface
   - Create location tracking
   - Design navigation experience

2. **Request Management**
   - Develop request cards
   - Create accept/reject flow
   - Implement status updates

3. **Driver Dashboard**
   - Design earnings tracking
   - Create trip history interface
   - Implement rating system

### Phase 5: Testing & Refinement (2 Weeks)

1. **Usability Testing**
   - Conduct user testing sessions
   - Gather feedback on new interfaces
   - Identify pain points and opportunities

2. **Performance Optimization**
   - Optimize animations for smooth performance
   - Reduce memory usage
   - Improve load times

3. **Accessibility Refinement**
   - Ensure color contrast compliance
   - Verify screen reader compatibility
   - Test with various input methods

## Conclusion

The proposed UI/UX enhancements will transform HeaLyri from a functional application to a premium, market-ready healthcare platform with distinctive visual identity and superior user experience. By focusing on modern design principles, engaging interactions, and role-specific interfaces, HeaLyri will stand out in the healthcare app market while providing an intuitive and accessible experience for all users.

The implementation plan provides a structured approach to realizing this vision over a 14-week timeline, with clear milestones and deliverables for each phase. This phased approach allows for iterative testing and refinement throughout the development process, ensuring that the final product meets both user needs and business objectives.
