import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'landing/welcome_screen.dart';
import 'landing/onboarding_screen.dart';
import 'landing/splash_screen.dart';
import 'shared/theme.dart';
import 'shared/constants.dart';
import 'shared/empty_state_example.dart';
import 'auth/auth_wrapper.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kIsWeb) {
    try {
      // Enable persistence for offline support and optimistic UI updates
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true, 
        sslEnabled: true,
      );
      debugPrint('Firestore persistence enabled for Web');
    } catch (e) {
      debugPrint('Error enabling persistence: $e');
    }
  }
  
  // Initialize Firebase Performance (works on all platforms)
  try {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  } catch (e) {
    // Performance may not be available on all platforms
    debugPrint('Firebase Performance initialization failed: $e');
  }
  
  // Initialize Firebase Crashlytics (mobile platforms only - not supported on web)
  // Note: Crashlytics is not available on web, so we skip it entirely
  if (!kIsWeb) {
    try {
      // Check if Crashlytics is actually available before using it
      final crashlytics = FirebaseCrashlytics.instance;
      
      FlutterError.onError = (errorDetails) {
        crashlytics.recordFlutterFatalError(errorDetails);
      };
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
      
      // Enable Crashlytics collection in production
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    } catch (e, stackTrace) {
      // Crashlytics initialization failed - log but don't crash
      debugPrint('Firebase Crashlytics initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  } else {
    // On web, set up basic error handling without Crashlytics
    FlutterError.onError = (errorDetails) {
      // Just log to console on web
      debugPrint('Flutter Error: ${errorDetails.exception}');
      debugPrint('Stack: ${errorDetails.stack}');
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      debugPrint('Stack: $stack');
      return true;
    };
  }
  
  runApp(const HeaLyriApp());
}

class HeaLyriApp extends StatelessWidget {
  const HeaLyriApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set this to false to skip the onboarding screen after splash
    // In a real app, this would be determined by checking if it's the first launch
    const bool showOnboarding = false;
    
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      
      // Start with the splash screen, which will navigate to the auth wrapper
      home: const SplashScreen(showOnboarding: showOnboarding),
      
      // Define named routes for easy navigation
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthWrapper(),
        '/empty_state_examples': (context) => const EmptyStateExample(),
      },
    );
  }
}
