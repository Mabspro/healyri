import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'logger.dart';

/// Centralized error handling service
/// 
/// Provides consistent error handling across the application,
/// including user-friendly error messages and automatic error reporting.
class ErrorHandler {
  /// Handle errors with user-friendly messages
  static void handleError(
    BuildContext context,
    dynamic error, {
    StackTrace? stackTrace,
    String? userMessage,
    bool showSnackBar = true,
  }) {
    // Log error
    AppLogger.e('Error occurred', error, stackTrace);

    // Report to Crashlytics (mobile platforms only)
    if (!kIsWeb && error != null && stackTrace != null) {
      try {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: false,
        );
      } catch (e) {
        // Crashlytics not available - just log
        AppLogger.w('Crashlytics unavailable for error reporting', e);
      }
    }

    // Show user-friendly message
    if (showSnackBar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage ?? getErrorMessage(error)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Get user-friendly error message from error object
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getAuthErrorMessage(error.code);
    }
    
    if (error is FirebaseException) {
      return 'A Firebase error occurred. Please try again.';
    }
    
    // Generic error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get user-friendly message for Firebase Auth errors
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'sign-in-cancelled':
        return 'Sign in was cancelled. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method. Please use the original sign-in method.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid. Please try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign out and sign in again.';
      default:
        AppLogger.w('Unknown Firebase Auth error code: $code');
        return 'An authentication error occurred. Please try again.';
    }
  }

  /// Show error dialog instead of snackbar for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? buttonText,
  }) async {
    if (!context.mounted) return;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(buttonText ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

