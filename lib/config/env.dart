/// Environment configuration management
/// 
/// This file manages environment-specific configuration values.
/// For production, use environment variables or build-time configuration.
class Env {
  // Firebase Configuration
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'healyri-af36a',
  );

  // Environment detection
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://us-central1-healyri-af36a.cloudfunctions.net',
  );

  // Feature Flags
  static const bool enableCrashlytics = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  static const bool enablePerformanceMonitoring = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_MONITORING',
    defaultValue: true,
  );

  // App Configuration
  static const String appName = 'HeaLyri';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Logging
  static bool get enableVerboseLogging => isDevelopment;
  static bool get enableDebugLogging => isDevelopment || isStaging;

  // Emergency System Configuration
  static const int emergencyTimeoutSeconds = 300; // 5 minutes
  static const int maxEmergencyRetries = 3;
  static const double defaultEmergencyRadiusKm = 50.0;

  // Location Configuration
  static const int locationUpdateIntervalSeconds = 30;
  static const double locationAccuracyMeters = 100.0;

  // Network Configuration
  static const int requestTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  /// Get environment-specific configuration
  static Map<String, dynamic> getConfig() {
    return {
      'environment': environment,
      'firebaseProjectId': firebaseProjectId,
      'apiBaseUrl': apiBaseUrl,
      'enableCrashlytics': enableCrashlytics,
      'enableAnalytics': enableAnalytics,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'appName': appName,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
    };
  }
}

