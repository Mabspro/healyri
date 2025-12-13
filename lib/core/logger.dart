import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized logging service for the application
/// 
/// Provides different log levels and automatically reports errors
/// to Firebase Crashlytics in production builds (mobile platforms only).
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.debug : Level.warning,
  );

  /// Check if Crashlytics is available (not on web)
  static bool get _isCrashlyticsAvailable => !kIsWeb;

  /// Log debug messages (only in debug mode)
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info messages
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    if (_isCrashlyticsAvailable && !kDebugMode) {
      try {
        FirebaseCrashlytics.instance.log('WARNING: $message');
      } catch (e) {
        // Crashlytics not available - just log normally
        _logger.w('Crashlytics unavailable: $e');
      }
    }
  }

  /// Log error messages and report to Crashlytics (mobile only)
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (_isCrashlyticsAvailable) {
      try {
        if (error != null && stackTrace != null) {
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: message,
            fatal: false,
          );
        } else if (!kDebugMode) {
          FirebaseCrashlytics.instance.log('ERROR: $message');
        }
      } catch (e) {
        // Crashlytics not available - just log normally
        _logger.e('Crashlytics unavailable: $e');
      }
    }
  }

  /// Log fatal errors (app should terminate)
  static void f(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    if (_isCrashlyticsAvailable) {
      try {
        if (error != null && stackTrace != null) {
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: message,
            fatal: true,
          );
        }
      } catch (e) {
        // Crashlytics not available - just log normally
        _logger.f('Crashlytics unavailable: $e');
      }
    }
  }
}

