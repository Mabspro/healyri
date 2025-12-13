class AppConstants {
  // App Information
  static const String appName = 'HeaLyri';
  static const String appTagline = 'Your Health Journey, Simplified';
  static const String appDescription = 'HeaLyri connects you with healthcare providers, simplifies appointment booking, and helps you manage your health journey.';
  
  // Feature Titles
  static const String appointmentBookingTitle = 'Appointment Booking';
  static const String facilityDirectoryTitle = 'Facility Directory';
  static const String telehealthTitle = 'Telehealth';
  static const String emergencyTitle = 'Emergency';
  static const String medicationsTitle = 'Medications';
  static const String aiTriageTitle = 'AI Health Assistant';
  static const String profileTitle = 'Profile';
  
  // Feature Descriptions
  static const String appointmentBookingDesc = 'Easily book appointments with healthcare providers in your area.';
  static const String facilityDirectoryDesc = 'Find healthcare facilities and providers near you.';
  static const String telehealthDesc = 'Connect with healthcare providers remotely through video calls.';
  static const String emergencyDesc = 'Quick access to emergency services and nearby facilities.';
  static const String medicationsDesc = 'Verify medication authenticity and get reminders.';
  static const String aiTriageDesc = 'Get AI-powered health guidance and symptom assessment.';
  static const String profileDesc = 'Manage your health profile and medical history.';
  
  // Button Labels
  static const String getStartedLabel = 'Get Started';
  static const String loginLabel = 'Login';
  static const String signUpLabel = 'Sign Up';
  static const String continueLabel = 'Continue';
  static const String cancelLabel = 'Cancel';
  static const String saveLabel = 'Save';
  
  // Section Titles
  static const String keyFeaturesTitle = 'Key Features';
  static const String howItWorksTitle = 'How It Works';
  
  // How It Works Steps
  static const String step1Title = 'Create an Account';
  static const String step1Desc = 'Sign up and create your health profile.';
  static const String step2Title = 'Find a Provider';
  static const String step2Desc = 'Search for healthcare providers in your area.';
  static const String step3Title = 'Book Appointment';
  static const String step3Desc = 'Select a time slot and book your appointment.';
  static const String step4Title = 'Receive Care';
  static const String step4Desc = 'Visit the facility or connect via telehealth.';
  
  // Layout Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 16.0;
  static const double buttonBorderRadius = 30.0;
  static const double cardBorderRadius = 16.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 36.0;
  
  // Animation Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // API Constants
  static const String apiBaseUrl = 'https://api.healyri.com';
  
  // Asset Paths
  static const String logoPath = 'assets/images/logo/logo.png';
  static const String placeholderImagePath = 'assets/images/illustrations/placeholder.png';
}
