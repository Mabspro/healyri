# HeaLyri Project Review & Enhancement Plan

**Review Date:** December 2024  
**Reviewer:** Senior Development Team  
**Project Status:** MVP Development Phase  
**External Validation:** ✅ [Antigravity Review](EXTERNAL_VALIDATION.md) - December 12, 2025

---

## Executive Summary

HeaLyri is a well-conceived healthcare platform for Zambia with solid architectural foundations. The project demonstrates good planning, comprehensive documentation, and a clear vision. However, there are several areas requiring attention before production readiness, including code quality improvements, security hardening, testing coverage, and architectural refinements.

**⚠️ Critical Finding (Validated by External Review):** The Emergency Button is currently a UI facade with zero backend logic. There is no dispatch system, no driver coordination, and no facility alerting. This "Air Gap" between product promise and system reality is the primary blocker.

**Overall Assessment:** ⭐⭐⭐⭐ (4/5) - Strong foundation with clear path to production  
**Current State:** Vision + docs = institutional-grade ✅ | Implementation gap = pre-infrastructure ⚠️

> **See [EXTERNAL_VALIDATION.md](EXTERNAL_VALIDATION.md) for independent validation of this assessment.**

---

## 1. Project Understanding

### 1.1 Core Purpose
HeaLyri is a comprehensive mobile healthcare platform designed to address critical healthcare access challenges in Zambia. The platform connects patients with healthcare providers through:

- **Appointment Scheduling** with private and public clinics/hospitals
- **Facility Directory** for finding healthcare providers
- **Medication Verification** to combat counterfeit medications
- **Telehealth Consultations** with local and international specialists
- **AI-Powered Triage** for symptom assessment and healthcare guidance
- **Emergency Services** for quick access to emergency care
- **Role-Based Architecture** supporting Patients, Providers, and Drivers

### 1.2 Technology Stack
- **Frontend:** Flutter (Cross-platform mobile)
- **Backend:** Firebase (Authentication, Firestore, Cloud Functions, Storage)
- **State Management:** Provider pattern
- **Architecture:** Role-based, modular design

### 1.3 Current Development Phase
The project is in **MVP Development Phase** with:
- ✅ Core authentication implemented
- ✅ Basic UI/UX structure in place
- ✅ Firebase backend configured
- ✅ Role-based access control foundation
- ⚠️ Many features are scaffolded but not fully implemented
- ⚠️ Limited error handling and validation
- ⚠️ Minimal test coverage
- 🔴 **CRITICAL:** Emergency flow is UI-only with no backend implementation (validated by external review)

---

## 2. Strengths

### 2.1 Documentation Excellence
- **Comprehensive planning documents** covering vision, architecture, database schema, and deployment
- **Clear executive summary** with strategic direction
- **Well-documented database schema** with security rules
- **Architecture documentation** with system diagrams

### 2.2 Solid Architecture Foundation
- **Role-based architecture** properly designed
- **Firebase integration** correctly implemented
- **Modular code structure** with clear separation of concerns
- **Theme system** well-organized and consistent

### 2.3 Good UI/UX Foundation
- **Modern design system** with Google Fonts integration
- **Consistent theming** across the application
- **Responsive components** with proper styling
- **Accessibility considerations** in design

### 2.4 Security Awareness
- **Firestore security rules** implemented
- **Role-based access control** in place
- **Email verification** required for users
- **Custom claims** for role management

---

## 3. Critical Issues & Improvements

### 3.0 The "Air Gap" Problem (CRITICAL - Validated by External Review)

**Status:** 🔴 **BLOCKER**

**Finding:**
The Emergency Button (`lib/emergency/emergency_button.dart`) is currently a **UI facade with zero backend logic**. This is the core value proposition, and it does not exist in code.

**What Exists:**
- ✅ FloatingActionButton UI
- ✅ Static dialogs
- ✅ Hardcoded phone numbers
- ✅ Hardcoded hospital list
- ❌ `// TODO: Implement call functionality`

**What's Missing:**
- ❌ No `emergencies` collection in Firestore
- ❌ No `EmergencyService` implementation
- ❌ No Cloud Functions for dispatch
- ❌ No geospatial querying (finding nearest hospital)
- ❌ No push notification logic
- ❌ No driver coordination
- ❌ No facility alerting
- ❌ No event/audit trail

**Impact:**
> "In its current state, it is a prototype, not a platform. It cannot handle a single real world emergency."

**Validation:**
This finding has been independently confirmed by external review. See [EXTERNAL_VALIDATION.md](EXTERNAL_VALIDATION.md).

**Resolution:**
This is addressed in the 4-week execution plan. See [EXECUTION_CHECKLIST.md](EXECUTION_CHECKLIST.md).

---

### 3.1 Code Quality Issues

#### 🔴 High Priority

**1. Error Handling Inconsistency**
- **Issue:** Mix of `print()` statements and proper error handling
- **Location:** Throughout codebase (e.g., `signin_screen.dart`, `auth_service.dart`)
- **Impact:** Poor error visibility, difficult debugging
- **Recommendation:**
  ```dart
  // Replace print() with proper logging
  import 'package:logger/logger.dart';
  final logger = Logger();
  logger.e('Error message', error: e, stackTrace: stackTrace);
  ```

**2. Missing Null Safety Checks**
- **Issue:** Potential null pointer exceptions
- **Location:** Multiple files, especially in `auth_wrapper.dart`
- **Impact:** App crashes, poor user experience
- **Recommendation:** Add comprehensive null checks and use null-aware operators

**3. Hardcoded Values**
- **Issue:** Mock data and hardcoded strings in production code
- **Location:** `home_screen.dart` (userName, appointment data)
- **Impact:** Not production-ready, difficult to maintain
- **Recommendation:** Move to service layer with proper data fetching

**4. Incomplete Feature Implementation**
- **Issue:** Many screens are placeholders or have incomplete functionality
- **Location:** Booking, Telehealth, Medication Verification, AI Triage
- **Impact:** Core features not functional
- **Recommendation:** Implement core business logic for each feature

#### 🟡 Medium Priority

**5. State Management**
- **Issue:** Using setState() instead of proper state management
- **Location:** Multiple screens
- **Impact:** Difficult to scale, poor separation of concerns
- **Recommendation:** Implement proper Provider/Riverpod/Bloc pattern

**6. Code Duplication**
- **Issue:** Repeated code patterns across screens
- **Location:** Authentication screens, form validation
- **Impact:** Maintenance burden, inconsistency
- **Recommendation:** Create reusable widgets and utilities

**7. Missing Input Validation**
- **Issue:** Limited client-side validation
- **Location:** Forms throughout the app
- **Impact:** Poor data quality, security risks
- **Recommendation:** Implement comprehensive form validation

### 3.2 Security Concerns

#### 🔴 High Priority

**1. Firestore Security Rules Gaps**
- **Issue:** Rules are basic and may have vulnerabilities
- **Location:** `firestore.rules`
- **Impact:** Potential unauthorized access
- **Recommendation:**
  - Add field-level validation
  - Implement rate limiting
  - Add data validation rules
  - Test rules thoroughly

**2. Missing Input Sanitization**
- **Issue:** No sanitization of user inputs
- **Location:** All forms and API calls
- **Impact:** Injection attacks, data corruption
- **Recommendation:** Implement input sanitization and validation

**3. Sensitive Data in Logs**
- **Issue:** Potential logging of sensitive information
- **Location:** Throughout codebase
- **Impact:** Privacy violations, security breaches
- **Recommendation:** Implement secure logging practices

#### 🟡 Medium Priority

**4. Token Management**
- **Issue:** FCM tokens not properly managed
- **Location:** User authentication flow
- **Impact:** Notification delivery issues
- **Recommendation:** Implement proper token refresh and cleanup

**5. Session Management**
- **Issue:** Basic session handling
- **Location:** Authentication service
- **Impact:** Security vulnerabilities
- **Recommendation:** Implement proper session timeout and refresh

### 3.3 Architecture Improvements

#### 🔴 High Priority

**1. Service Layer Missing**
- **Issue:** Business logic mixed with UI code
- **Location:** Throughout the app
- **Impact:** Difficult to test, maintain, and scale
- **Recommendation:** Create dedicated service layer:
  ```
  lib/
    services/
      appointment_service.dart
      facility_service.dart
      medication_service.dart
      telehealth_service.dart
      triage_service.dart
  ```

**2. Repository Pattern Not Implemented**
- **Issue:** Direct Firestore access from UI
- **Location:** Multiple screens
- **Impact:** Tight coupling, difficult testing
- **Recommendation:** Implement repository pattern for data access

**3. Dependency Injection Missing**
- **Issue:** Services instantiated directly
- **Location:** Throughout codebase
- **Impact:** Difficult testing, tight coupling
- **Recommendation:** Implement dependency injection (get_it, injectable)

#### 🟡 Medium Priority

**4. Error Handling Strategy**
- **Issue:** No centralized error handling
- **Location:** Throughout app
- **Impact:** Inconsistent error handling
- **Recommendation:** Create error handling service and custom exceptions

**5. Configuration Management**
- **Issue:** Hardcoded configuration values
- **Location:** Multiple files
- **Impact:** Difficult to manage environments
- **Recommendation:** Implement environment-based configuration

### 3.4 Testing Coverage

#### 🔴 Critical - No Test Coverage

**Current State:**
- Minimal test files exist but appear incomplete
- No integration tests
- No widget tests for critical flows
- No unit tests for services

**Recommendation:**
1. **Unit Tests:** Services, repositories, utilities (Target: 80% coverage)
2. **Widget Tests:** Critical UI components and flows
3. **Integration Tests:** End-to-end user journeys
4. **Firestore Rules Tests:** Security rule validation

### 3.5 Performance Issues

#### 🟡 Medium Priority

**1. No Caching Strategy**
- **Issue:** Data fetched repeatedly
- **Impact:** Poor performance, increased costs
- **Recommendation:** Implement caching for facilities, user data

**2. Image Optimization Missing**
- **Issue:** No image compression or lazy loading
- **Impact:** Poor performance on slow connections
- **Recommendation:** Implement image optimization and lazy loading

**3. No Pagination**
- **Issue:** Loading all data at once
- **Impact:** Slow initial load, high memory usage
- **Recommendation:** Implement pagination for lists

**4. No Offline Support**
- **Issue:** App requires constant connectivity
- **Impact:** Poor UX in areas with intermittent connectivity
- **Recommendation:** Implement Firestore offline persistence

---

## 4. Enhancement Recommendations

### 4.1 Immediate Enhancements (Sprint 1-2)

#### 1. Error Handling & Logging
```dart
// Create lib/core/error_handler.dart
class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    // Log to Firebase Crashlytics
    // Show user-friendly message
    // Report to analytics
  }
}

// Create lib/core/logger.dart
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    level: kDebugMode ? Level.debug : Level.warning,
  );
  
  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

#### 2. Service Layer Implementation
```dart
// lib/services/appointment_service.dart
class AppointmentService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  
  Future<Appointment> createAppointment({
    required String facilityId,
    required DateTime dateTime,
    required String serviceType,
  }) async {
    // Validation
    // Business logic
    // Firestore write
    // Error handling
  }
  
  Stream<List<Appointment>> getPatientAppointments() {
    // Real-time stream of appointments
  }
}
```

#### 3. Repository Pattern
```dart
// lib/repositories/appointment_repository.dart
abstract class AppointmentRepository {
  Future<Appointment> create(Appointment appointment);
  Stream<List<Appointment>> getByPatientId(String patientId);
  Future<void> update(String id, Map<String, dynamic> updates);
}

class FirestoreAppointmentRepository implements AppointmentRepository {
  // Implementation
}
```

#### 4. Input Validation
```dart
// lib/core/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? phoneNumber(String? value) {
    // Zambia phone number validation
  }
}
```

### 4.2 Medium-Term Enhancements (Sprint 3-6)

#### 1. State Management Refactoring
- Implement Provider/Riverpod for state management
- Create view models for complex screens
- Implement proper state persistence

#### 2. Offline Support
```dart
// Enable Firestore offline persistence
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

#### 3. Caching Strategy
```dart
// lib/services/cache_service.dart
class CacheService {
  static const Duration defaultCacheDuration = Duration(hours: 1);
  
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration? duration,
  }) async {
    // Check cache
    // Fetch if expired
    // Update cache
  }
}
```

#### 4. Image Optimization
- Implement image caching
- Add lazy loading for images
- Compress images before upload
- Use CDN for image delivery

### 4.3 Long-Term Enhancements (Sprint 7+)

#### 1. Advanced Features
- Real-time appointment notifications
- Payment integration (Mobile Money)
- AI Triage implementation
- Telehealth video integration
- Medication barcode scanning

#### 2. Analytics & Monitoring
- Comprehensive analytics implementation
- Performance monitoring
- User behavior tracking
- Error tracking and alerting

#### 3. Internationalization
- Multi-language support (English, local languages)
- Cultural adaptation
- Localized date/time formats

#### 4. Accessibility
- Screen reader support
- High contrast mode
- Font size adjustment
- Voice commands

---

## 5. Code Quality Improvements

### 5.1 Linting & Formatting

**Current State:** Basic linting configuration

**Recommendations:**
1. Enable stricter linting rules:
```yaml
# analysis_options.yaml
linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - avoid_redundant_argument_values
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - use_key_in_widget_constructors
```

2. Add pre-commit hooks for formatting
3. Set up CI/CD for automated linting

### 5.2 Code Organization

**Recommended Structure:**
```
lib/
  core/
    constants/
    errors/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    appointments/
      data/
      domain/
      presentation/
    facilities/
      data/
      domain/
      presentation/
  shared/
    services/
    repositories/
    models/
```

### 5.3 Documentation

**Add:**
- Inline code documentation
- API documentation
- Architecture decision records (ADRs)
- Code review guidelines

---

## 6. Security Hardening

### 6.1 Firestore Rules Enhancement

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Enhanced helper functions
    function isValidEmail(email) {
      return email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
    }
    
    function isValidPhone(phone) {
      return phone.matches('^\\+260[0-9]{9}$');
    }
    
    function isValidRole(role) {
      return role in ['patient', 'provider', 'driver', 'admin'];
    }
    
    // Enhanced user rules with validation
    match /users/{userId} {
      allow read: if isAuthenticated() && (
        isOwner(userId) || 
        hasRole('provider') ||
        hasRole('admin')
      );
      
      allow create: if isAuthenticated() &&
        request.resource.data.keys().hasAll(['name', 'email', 'role', 'createdAt']) &&
        isValidRole(request.resource.data.role) &&
        isValidEmail(request.resource.data.email) &&
        request.resource.data.name.size() > 0 &&
        request.resource.data.name.size() <= 100;
      
      allow update: if isOwner(userId) &&
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['name', 'email', 'phone', 'address', 'updatedAt']) &&
        (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'isVerified']));
      
      allow delete: if isAdmin();
    }
    
    // Add rate limiting for appointments
    match /appointments/{appointmentId} {
      allow create: if isAuthenticated() &&
        request.resource.data.keys().hasAll(['patientId', 'facilityId', 'dateTime', 'status']) &&
        isOwner(request.resource.data.patientId) &&
        request.resource.data.dateTime > request.time &&
        request.resource.data.status == 'pending';
    }
  }
}
```

### 6.2 Data Validation

- Implement server-side validation in Cloud Functions
- Add input sanitization
- Implement rate limiting
- Add data encryption for sensitive fields

### 6.3 Authentication Security

- Implement MFA for providers and drivers
- Add session timeout
- Implement device fingerprinting
- Add suspicious activity detection

---

## 7. Testing Strategy

### 7.1 Unit Tests

```dart
// test/services/appointment_service_test.dart
void main() {
  group('AppointmentService', () {
    test('creates appointment successfully', () async {
      // Arrange
      // Act
      // Assert
    });
    
    test('throws error when facility not found', () async {
      // Test error handling
    });
  });
}
```

### 7.2 Widget Tests

```dart
// test/widgets/appointment_card_test.dart
void main() {
  testWidgets('displays appointment information correctly', (tester) async {
    // Test widget rendering
  });
}
```

### 7.3 Integration Tests

```dart
// integration_test/appointment_flow_test.dart
void main() {
  testWidgets('complete appointment booking flow', (tester) async {
    // Test end-to-end flow
  });
}
```

### 7.4 Test Coverage Goals

- **Unit Tests:** 80% coverage for services and repositories
- **Widget Tests:** All critical UI components
- **Integration Tests:** All major user flows
- **Firestore Rules Tests:** All security rules

---

## 8. Performance Optimization

### 8.1 Database Optimization

1. **Indexes:** Ensure all query patterns have indexes
2. **Pagination:** Implement for all list views
3. **Denormalization:** Add frequently accessed data to documents
4. **Query Optimization:** Minimize reads, use efficient queries

### 8.2 App Performance

1. **Lazy Loading:** Implement for images and lists
2. **Code Splitting:** Split large widgets into smaller ones
3. **Memory Management:** Proper disposal of controllers and streams
4. **Build Optimization:** Use const constructors where possible

### 8.3 Network Optimization

1. **Request Batching:** Batch multiple requests
2. **Caching:** Cache frequently accessed data
3. **Compression:** Compress data before transmission
4. **Retry Logic:** Implement smart retry for failed requests

---

## 9. Deployment Readiness Checklist

### 9.1 Pre-Production Requirements

- [ ] All critical features implemented and tested
- [ ] Security rules tested and validated
- [ ] Error handling implemented throughout
- [ ] Logging and monitoring configured
- [ ] Performance testing completed
- [ ] Security audit performed
- [ ] Privacy policy and terms of service
- [ ] Data backup strategy implemented
- [ ] Disaster recovery plan
- [ ] Documentation complete

### 9.2 Production Checklist

- [ ] Environment configuration (dev, staging, prod)
- [ ] CI/CD pipeline configured
- [ ] Monitoring and alerting set up
- [ ] Error tracking (Firebase Crashlytics)
- [ ] Analytics configured
- [ ] App store assets prepared
- [ ] Beta testing completed
- [ ] User acceptance testing
- [ ] Load testing completed
- [ ] Security penetration testing

---

## 10. Recommended Action Plan

### Phase 1: Foundation (Weeks 1-4)
1. ✅ Implement proper error handling and logging
2. ✅ Create service layer architecture
3. ✅ Implement repository pattern
4. ✅ Add comprehensive input validation
5. ✅ Enhance Firestore security rules
6. ✅ Set up dependency injection

### Phase 2: Core Features (Weeks 5-8)
1. ✅ Complete appointment booking implementation
2. ✅ Implement facility directory with real data
3. ✅ Add offline support
4. ✅ Implement caching strategy
5. ✅ Complete authentication flows

### Phase 3: Testing & Quality (Weeks 9-12)
1. ✅ Write unit tests (target 80% coverage)
2. ✅ Write widget tests for critical components
3. ✅ Write integration tests for key flows
4. ✅ Performance optimization
5. ✅ Security audit and fixes

### Phase 4: Advanced Features (Weeks 13-16)
1. ✅ Payment integration
2. ✅ Telehealth implementation
3. ✅ AI Triage basic implementation
4. ✅ Medication verification
5. ✅ Emergency services

### Phase 5: Production Preparation (Weeks 17-20)
1. ✅ Beta testing
2. ✅ Performance tuning
3. ✅ Security hardening
4. ✅ Documentation completion
5. ✅ App store preparation

---

## 11. Quick Wins (Can be done immediately)

1. **Replace print() with proper logging** (2 hours)
2. **Add const constructors** (1 hour)
3. **Fix null safety issues** (4 hours)
4. **Add input validation** (8 hours)
5. **Create error handling service** (4 hours)
6. **Add loading states** (4 hours)
7. **Improve Firestore rules** (4 hours)
8. **Add basic unit tests** (8 hours)

**Total Quick Wins:** ~35 hours of development

---

## 12. Conclusion

HeaLyri has a **strong foundation** with excellent documentation and clear vision. The main areas requiring attention are:

1. **Code Quality:** Error handling, null safety, service layer
2. **Security:** Enhanced rules, input validation, secure logging
3. **Testing:** Comprehensive test coverage
4. **Architecture:** Service layer, repository pattern, DI
5. **Performance:** Caching, offline support, optimization

With focused effort on these areas, the project can be production-ready within **4-5 months** of dedicated development.

### Priority Ranking:
1. 🔴 **Critical:** Error handling, security rules, service layer
2. 🟡 **High:** Testing, offline support, caching
3. 🟢 **Medium:** Advanced features, analytics, i18n

### Estimated Timeline to Production:
- **MVP Ready:** 3-4 months
- **Full Feature Set:** 6-8 months
- **Production Launch:** 8-10 months

---

## Appendix: Code Examples

### Example: Proper Service Implementation

```dart
// lib/services/appointment_service.dart
class AppointmentService {
  final AppointmentRepository _repository;
  final AuthService _authService;
  final Logger _logger;
  
  AppointmentService({
    required AppointmentRepository repository,
    required AuthService authService,
    required Logger logger,
  }) : _repository = repository,
       _authService = authService,
       _logger = logger;
  
  Future<Result<Appointment>> createAppointment({
    required String facilityId,
    required DateTime dateTime,
    required String serviceType,
  }) async {
    try {
      // Validation
      if (dateTime.isBefore(DateTime.now())) {
        return Result.failure(
          ValidationException('Appointment date must be in the future'),
        );
      }
      
      final user = _authService.currentUser;
      if (user == null) {
        return Result.failure(
          AuthenticationException('User not authenticated'),
        );
      }
      
      // Business logic
      final appointment = Appointment(
        patientId: user.uid,
        facilityId: facilityId,
        dateTime: dateTime,
        serviceType: serviceType,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
      );
      
      // Repository call
      final created = await _repository.create(appointment);
      
      _logger.i('Appointment created: ${created.id}');
      
      return Result.success(created);
    } catch (e, stackTrace) {
      _logger.e('Error creating appointment', error: e, stackTrace: stackTrace);
      return Result.failure(
        AppointmentException('Failed to create appointment', e),
      );
    }
  }
}
```

### Example: Repository Pattern

```dart
// lib/repositories/appointment_repository.dart
abstract class AppointmentRepository {
  Future<Appointment> create(Appointment appointment);
  Future<Appointment?> getById(String id);
  Stream<List<Appointment>> getByPatientId(String patientId);
  Future<void> update(String id, Map<String, dynamic> updates);
  Future<void> delete(String id);
}

class FirestoreAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _firestore;
  
  FirestoreAppointmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<Appointment> create(Appointment appointment) async {
    try {
      final docRef = await _firestore
          .collection('appointments')
          .add(appointment.toJson());
      
      final doc = await docRef.get();
      return Appointment.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw RepositoryException('Failed to create appointment', e);
    }
  }
  
  @override
  Stream<List<Appointment>> getByPatientId(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromJson(doc.data(), doc.id))
            .toList());
  }
}
```

---

**End of Review**

