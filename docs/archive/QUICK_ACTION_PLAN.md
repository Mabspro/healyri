# HeaLyri Quick Action Plan

**Priority Actions for Immediate Implementation**

---

## 🚨 Critical Fixes (Do First - Week 1)

### 1. Replace print() with Proper Logging
**Files to Update:**
- `lib/auth/signin_screen.dart`
- `lib/auth/signup_screen.dart`
- `lib/services/auth_service.dart`
- All other files using `print()`

**Action:**
```dart
// Add to pubspec.yaml
dependencies:
  logger: ^2.0.2+1
  firebase_crashlytics: ^3.4.9

// Create lib/core/logger.dart
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    FirebaseCrashlytics.instance.log(message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (error != null && stackTrace != null) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }
}
```

### 2. Fix Null Safety Issues
**Files to Update:**
- `lib/auth/auth_wrapper.dart` - Multiple potential null issues
- `lib/home/home_screen.dart` - Mock data handling

**Action:** Add comprehensive null checks and use null-aware operators

### 3. Create Error Handling Service
**New File:** `lib/core/error_handler.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'logger.dart';

class ErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error,
    StackTrace? stackTrace, {
    String? userMessage,
  }) {
    // Log error
    AppLogger.e('Error occurred', error, stackTrace);
    
    // Report to Crashlytics
    if (error != null && stackTrace != null) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
    
    // Show user-friendly message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage ?? 'An error occurred. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password is too weak.';
        default:
          return 'Authentication error. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
```

### 4. Enhance Firestore Security Rules
**File:** `firestore.rules`

Add field validation and enhanced security checks (see PROJECT_REVIEW.md section 6.1)

---

## 🔧 High Priority (Week 2-3)

### 5. Create Service Layer
**New Files:**
- `lib/services/appointment_service.dart`
- `lib/services/facility_service.dart`
- `lib/services/medication_service.dart`
- `lib/services/telehealth_service.dart`

### 6. Implement Repository Pattern
**New Files:**
- `lib/repositories/appointment_repository.dart`
- `lib/repositories/facility_repository.dart`
- `lib/repositories/base_repository.dart`

### 7. Add Input Validation
**New File:** `lib/core/validators.dart`

```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }
  
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Zambia phone number format: +260XXXXXXXXX
    final phoneRegex = RegExp(r'^\+260[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., +260XXXXXXXXX)';
    }
    return null;
  }
  
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
```

### 8. Set Up Dependency Injection
**Action:**
```yaml
# pubspec.yaml
dependencies:
  get_it: ^7.6.4
  injectable: ^2.3.2

dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.8
```

```dart
// lib/core/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

---

## 📋 Medium Priority (Week 4-6)

### 9. Implement Offline Support
```dart
// In main.dart after Firebase initialization
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 10. Add Caching Layer
**New File:** `lib/services/cache_service.dart`

### 11. Implement Loading States
Add proper loading indicators throughout the app

### 12. Add Error Boundaries
Create error boundary widgets for graceful error handling

---

## ✅ Quick Wins (Can be done in 1-2 hours each)

1. **Add const constructors** - Search for widgets that can be const
2. **Remove unused imports** - Run `flutter pub get` and clean up
3. **Fix deprecated code** - Update to latest Flutter patterns
4. **Add documentation comments** - Document public APIs
5. **Organize imports** - Use import sorter
6. **Fix linting issues** - Run `flutter analyze` and fix

---

## 📊 Testing Roadmap

### Phase 1: Unit Tests (Week 3-4)
- [ ] AuthService tests
- [ ] AppointmentService tests
- [ ] Validator tests
- [ ] Repository tests

### Phase 2: Widget Tests (Week 5-6)
- [ ] Auth screens tests
- [ ] Home screen tests
- [ ] Form validation tests

### Phase 3: Integration Tests (Week 7-8)
- [ ] Complete auth flow
- [ ] Appointment booking flow
- [ ] Profile update flow

---

## 🎯 Success Metrics

Track these metrics to measure improvement:

1. **Code Quality:**
   - Test coverage > 80%
   - Zero linting errors
   - All print() statements replaced

2. **Performance:**
   - App startup time < 2 seconds
   - Screen load time < 1 second
   - Memory usage optimized

3. **Security:**
   - All security rules tested
   - Input validation on all forms
   - No sensitive data in logs

4. **User Experience:**
   - Error messages are user-friendly
   - Loading states on all async operations
   - Offline support working

---

## 📝 Daily Checklist

For each development session:

- [ ] Run `flutter analyze` before committing
- [ ] Write/update tests for new code
- [ ] Update documentation
- [ ] Check for null safety issues
- [ ] Verify error handling
- [ ] Test on both iOS and Android

---

## 🚀 Getting Started

1. **Today:** Set up logging and error handling
2. **This Week:** Fix critical issues and add validation
3. **This Month:** Implement service layer and testing
4. **Next Month:** Advanced features and optimization

---

**Remember:** Small, incremental improvements are better than trying to fix everything at once. Focus on one area at a time and test thoroughly.

