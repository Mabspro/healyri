# HeaLyri - Healthcare Platform for Zambia

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

HeaLyri is a comprehensive mobile healthcare platform designed to address critical healthcare access challenges in Zambia. This repository contains the code and documentation for the HeaLyri mobile application.

## 🎯 Project Overview

HeaLyri is **Zambia's digital front door to healthcare** - not just an app, but an early national health interface layer.

**Strategic Focus:** Emergency → Transport → Facility flow (our wedge)

> **✅ Current State:** Emergency coordination platform successfully implemented. Emergency-first architecture, commitment view, and patient dashboard dominance completed. See [docs/PLATFORM_REVIEW.md](docs/PLATFORM_REVIEW.md) for comprehensive review and [docs/NEXT_STEPS.md](docs/NEXT_STEPS.md) for upcoming work.

HeaLyri connects patients with healthcare providers through an integrated platform offering:

- **Emergency Services** ⭐ (Primary Focus) - Emergency routing, dispatch, and coordination
- **Facility Directory** - Find verified healthcare facilities
- **Appointment Scheduling** - Book appointments with clinics/hospitals
- **Multi-Role Support** - Patients, Providers, and Drivers
- **Medication Verification** - Verify medication authenticity
- **Telehealth Consultations** - Remote healthcare access
- **AI-Powered Triage** - Symptom assessment and guidance

## ✨ Recent Improvements (December 2024)

### ✅ Completed - Emergency Coordination Shift

1. **Emergency-First Architecture**
   - ✅ Emergency state machine with canonical timestamps
   - ✅ Hybrid state + event architecture for auditability
   - ✅ Emergency service with real Firestore integration
   - ✅ Cloud Functions for automatic dispatch

2. **Reusable UI Components**
   - ✅ EmergencyStatusChip
   - ✅ EmergencyTimelineWidget
   - ✅ FallbackActionBar (Call/SMS backup)
   - ✅ ResponderCard & FacilityCard

3. **Emergency Commitment View**
   - ✅ Immediate reassurance after emergency trigger
   - ✅ Real-time elapsed timer
   - ✅ Dynamic next-step messages
   - ✅ Integrated timeline and responder cards

4. **Patient Dashboard Transformation**
   - ✅ Emergency-dominant layout
   - ✅ Active emergency banner/tracker
   - ✅ Context-aware Emergency FAB
   - ✅ Emergency Readiness module (replaces appointments)
   - ✅ Trust cues and coverage information

5. **UX/UI Improvements**
   - ✅ Emergency-focused onboarding messaging
   - ✅ Role selection with emergency one-liners
   - ✅ Human-readable location display
   - ✅ Mobile-first responsive design
   - ✅ Custom page transitions

6. **Infrastructure**
   - ✅ Logging infrastructure (AppLogger)
   - ✅ Error handling service
   - ✅ Input validation
   - ✅ Firebase Hosting deployment
   - ✅ Git repository setup

### 🚧 In Progress

- **Facility Model Integration** - Removing hardcoded facility data
- **Seed Data System** - Populating Firestore with real facilities
- **Documentation Updates** - Reflecting current state

### 📋 Next Steps

See [docs/NEXT_STEPS.md](docs/NEXT_STEPS.md) for detailed next steps:
- Remove all hardcoded facility data
- Integrate Facility model across all screens
- Seed production data
- Enhance location services
- Connect Emergency Readiness to real data

## 🏗️ Architecture

### Technology Stack

- **Frontend:** Flutter (Cross-platform: iOS, Android, Web)
- **Backend:** Firebase
  - Authentication
  - Cloud Firestore (Database)
  - Cloud Functions (Serverless)
  - Cloud Storage (Files)
  - Cloud Messaging (Notifications)
  - Analytics & Performance
- **State Management:** Provider
- **Logging:** Logger + Firebase Crashlytics

### Project Structure

```
healyri/
├── lib/
│   ├── core/                    # Core utilities
│   │   ├── logger.dart         # Logging service
│   │   ├── error_handler.dart  # Error handling
│   │   └── validators.dart     # Input validation
│   ├── services/                # Business logic services
│   │   ├── auth_service.dart
│   │   └── performance_service.dart
│   ├── auth/                   # Authentication screens
│   ├── home/                   # Home screens
│   ├── booking/                # Appointment booking
│   ├── facility_directory/     # Healthcare facility directory
│   ├── emergency/              # Emergency services
│   ├── telehealth/             # Telehealth consultations
│   ├── medications/            # Medication verification
│   ├── ai_triage/              # AI-powered triage
│   ├── profile/                # User profile management
│   ├── provider/                # Provider dashboard
│   ├── driver/                  # Driver interface
│   ├── shared/                 # Shared components and utilities
│   └── main.dart               # Application entry point
├── assets/                      # Static assets
│   └── images/                 # Image resources
├── docs/                        # Project documentation
│   ├── PROJECT_REVIEW.md      # Comprehensive technical review
│   ├── QUICK_ACTION_PLAN.md   # Implementation guide
│   ├── DEVELOPMENT_SETUP.md   # Development environment guide
│   └── TROUBLESHOOTING.md     # Troubleshooting guide
├── functions/                  # Cloud Functions (Node.js/TypeScript)
├── firestore.rules            # Firestore security rules
└── pubspec.yaml               # Flutter dependencies
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase account and project
- Android Studio / VS Code with Flutter extensions
- Chrome browser (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/healyri.git
   cd healyri
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Ensure `firebase_options.dart` is configured
   - Set up Firebase project in Firebase Console
   - Configure authentication providers

4. **Run the app**
   ```bash
   # Web (Recommended for development)
   flutter run -d chrome --web-port=8080
   
   # Android
   flutter run -d <device-id>
   
   # iOS (Mac only)
   flutter run -d <device-id>
   ```

### Development Setup

For detailed development setup instructions, see [DEVELOPMENT_SETUP.md](docs/DEVELOPMENT_SETUP.md).

**Quick Start:**
```bash
# Clean and rebuild
flutter clean && flutter pub get

# Run on Chrome
flutter run -d chrome --web-port=8080

# Hard refresh browser: Ctrl + Shift + R
```

## 📱 Features

### For Patients
- ✅ User authentication (Email, Google, Facebook)
- ✅ Role-based access control
- ✅ Healthcare facility directory
- ✅ Appointment booking (UI ready)
- ✅ Emergency services access
- ✅ Medication verification (UI ready)
- ✅ Telehealth consultations (UI ready)
- ✅ AI Triage chatbot (UI ready)
- ✅ Profile management

### For Providers
- ✅ Provider authentication and verification
- ✅ Provider dashboard
- ✅ Patient management (planned)
- ✅ Appointment management (planned)

### For Drivers
- ✅ Driver authentication and verification
- ✅ Driver dashboard
- ✅ Transport requests (planned)

## 🔒 Security

- **Authentication:** Firebase Authentication with multiple providers
- **Database:** Firestore security rules with role-based access
- **Storage:** Secure file uploads with access control
- **Error Reporting:** Crashlytics for production error tracking
- **Input Validation:** Comprehensive client and server-side validation

## 📊 Current Status

### Code Quality: ⭐⭐⭐⭐ (4/5)
- ✅ Proper logging implemented
- ✅ Error handling centralized
- ✅ Input validation added
- ⚠️ Service layer needs implementation
- ⚠️ Test coverage needs improvement

### Feature Completion: ~40%
- ✅ Authentication: 90% complete
- 🔴 **Emergency Services: 5% complete (UI facade only - CRITICAL GAP)**
- ⚠️ Appointment Booking: 30% complete (UI only)
- ⚠️ Facility Directory: 40% complete
- ⚠️ Telehealth: 20% complete (FROZEN)
- ⚠️ Medication Verification: 20% complete (FROZEN)
- ⚠️ AI Triage: 10% complete (FROZEN)

> **Note:** Emergency Services is the strategic wedge but currently has no backend. See [EXECUTION_CHECKLIST.md](docs/EXECUTION_CHECKLIST.md) for 4-week plan to close this gap.

### Production Readiness: ~30%
- ✅ Core infrastructure in place
- ✅ Error handling and logging
- ⚠️ Testing needed
- ⚠️ Security hardening needed
- ⚠️ Performance optimization needed

## 🛠️ Development

### Running the App

**Web (Recommended):**
```bash
flutter run -d chrome --web-port=8080
```

**Android:**
```bash
flutter run -d <android-device-id>
```

**iOS (Mac only):**
```bash
flutter run -d <ios-device-id>
```

### Code Quality Checks

```bash
# Run linter
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test
```

### Hot Reload

- **Hot Reload:** Press `r` in terminal (for UI changes)
- **Hot Restart:** Press `R` in terminal (for logic changes)
- **Quit:** Press `q` in terminal

### Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

**Common Issues:**
- **Blank page:** Hard refresh browser (Ctrl+Shift+R)
- **Crashlytics errors on web:** Expected - Crashlytics is mobile-only
- **Port conflicts:** Change port with `--web-port=8081`

## 🚀 Production Readiness

**⚠️ Pre-Production Status:** See [PRODUCTION_READINESS.md](docs/PRODUCTION_READINESS.md) for comprehensive assessment.

**Critical Actions Required:**
1. ✅ Initialize Git repository and push to GitHub
2. ✅ Set up separate Firebase projects (dev/staging/prod)
3. ✅ Configure Android/iOS release signing
4. ✅ Create Privacy Policy and Terms of Service
5. ✅ Deploy web app to Firebase Hosting

**Current Status:**
- ❌ **Git Repository:** Not initialized
- ⚠️ **Hosting:** Firebase configured but not deployed
- ⚠️ **Security:** API keys in code, no environment management
- ❌ **Signing:** Release signing not configured
- ❌ **Legal:** Privacy Policy and Terms missing

## 📚 Documentation

### Strategic Documents
- **[PRODUCTION_READINESS.md](docs/PRODUCTION_READINESS.md)** ⭐ **PRODUCTION PREP** - Comprehensive production readiness assessment
- **[EXECUTION_CHECKLIST.md](docs/EXECUTION_CHECKLIST.md)** ⭐ **START HERE** - Master gate-based execution checklist
- **[EXTERNAL_VALIDATION.md](docs/EXTERNAL_VALIDATION.md)** - Independent external review validation (Antigravity)
- **[COMMITMENT.md](docs/COMMITMENT.md)** - Strategic commitment and execution framework
- **[EXECUTION_PLAN.md](docs/EXECUTION_PLAN.md)** - Detailed day-by-day execution plan
- **[STRATEGIC_RECOMMENDATIONS.md](docs/STRATEGIC_RECOMMENDATIONS.md)** - Strategic direction and recommendations
- **[SYSTEM_LEVEL_ANALYSIS.md](docs/SYSTEM_LEVEL_ANALYSIS.md)** - Technical system-level analysis

**See [docs/README.md](docs/README.md) for complete documentation index**

### Architecture Documents
- **[HYBRID_ARCHITECTURE.md](docs/HYBRID_ARCHITECTURE.md)** - State + Event architecture design
- **[OPERATIONAL_MODEL.md](docs/OPERATIONAL_MODEL.md)** - Operational responsibility model

### Technical Documents
- **[PROJECT_REVIEW.md](docs/PROJECT_REVIEW.md)** - Comprehensive technical review (includes "Air Gap" analysis)
- **[QUICK_ACTION_PLAN.md](docs/QUICK_ACTION_PLAN.md)** - Step-by-step implementation guide
- **[DEVELOPMENT_SETUP.md](docs/DEVELOPMENT_SETUP.md)** - Development environment setup
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[REVIEW_SUMMARY.md](docs/REVIEW_SUMMARY.md)** - Executive summary

## 🎯 Strategic Roadmap

### ⚡ Current Focus: Emergency Flow (4-Week Sprint)

**Commitment:** Emergency → Transport → Facility closed-loop by end of Week 4

**Week 1-2:** Emergency Backend Foundation
- [ ] Emergency data model (state + events)
- [ ] EmergencyService implementation
- [ ] Facility routing
- [ ] Manual operations model

**Week 3-4:** Coordination + Resolution
- [ ] Driver assignment
- [ ] Real-time tracking
- [ ] Facility acknowledgment
- [ ] Emergency resolution
- [ ] Complete audit trail

**Definition of Done:**
- ✅ Emergency can be created, routed, acknowledged, tracked, and resolved
- ✅ Full audit trail exists
- ✅ 3 facilities + 5 drivers onboarded
- ✅ End-to-end test successful

**See [EXECUTION_CHECKLIST.md](docs/EXECUTION_CHECKLIST.md) for master execution checklist**  
**See [EXECUTION_PLAN.md](docs/EXECUTION_PLAN.md) for detailed day-by-day plan**

### Phase 1: Foundation (Completed ✅)
- [x] Authentication system
- [x] Logging and error handling
- [x] Input validation
- [x] Firebase package updates
- [x] Platform compatibility fixes
- [x] Strategic direction confirmed

### Phase 2: Emergency Flow (In Progress 🚧)
- [ ] Emergency backend (Week 1-2)
- [ ] Coordination system (Week 3-4)
- [ ] Controlled pilot (Week 4)

**Target:** End of Week 4  
**Progress:** 0% (Starting Week 1)

### Phase 3: Expansion (Planned 📋)
- [ ] More facilities (10+)
- [ ] More drivers (20+)
- [ ] Automation improvements
- [ ] Analytics dashboard
- [ ] Ministry engagement

**Target:** Month 2-3  
**Progress:** 0%

### Phase 4: Other Features (Frozen ⏸️)
- [ ] Appointment booking (frozen until emergency complete)
- [ ] Telehealth (frozen)
- [ ] AI Triage (frozen)
- [ ] Medication verification (frozen)

**Status:** All features frozen except Emergency + Facilities

## 🔧 Strategic Direction

### ✅ Committed To

1. **Emergency Flow as Wedge** (Non-negotiable)
   - Full closed-loop implementation
   - Emergency → Transport → Facility
   - 4-week deadline

2. **Hybrid Architecture** (Formalized)
   - State collections (current snapshot)
   - Event collections (append-only audit trail)
   - Healthcare-grade architecture

3. **Feature Freeze** (Discipline)
   - Emergency + Facilities only
   - All other features frozen
   - No distractions

4. **Ministry-Ready Data** (From day 1)
   - Standardized timestamps
   - Clear resolution outcomes
   - Response time tracking

**See [COMMITMENT.md](docs/COMMITMENT.md) for full strategic commitment**

## 📈 Progress Tracking

### Completed ✅
- [x] Project review and analysis
- [x] Logging infrastructure
- [x] Error handling service
- [x] Input validation utilities
- [x] Code cleanup (removed unused code)
- [x] Firebase package updates
- [x] Platform compatibility fixes
- [x] Development environment setup

### In Progress 🚧
- [ ] Service layer architecture
- [ ] Repository pattern
- [ ] Enhanced security rules

### Planned 📋
- [ ] Complete core features
- [ ] Testing implementation
- [ ] Performance optimization
- [ ] Production deployment

## 🤝 Contributing

Contributions to HeaLyri are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow Flutter/Dart style guidelines
- Use `AppLogger` for logging (never `print()`)
- Use `ErrorHandler` for error handling
- Use `Validators` for input validation
- Write tests for new features
- Update documentation

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Ministry of Health, Zambia
- Healthcare providers and volunteers
- Open source community
- Firebase team for excellent tooling

## 📞 Support

For issues, questions, or contributions:
- Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues
- Review [DEVELOPMENT_SETUP.md](docs/DEVELOPMENT_SETUP.md) for setup help
- Open an issue on GitHub

---

**Last Updated:** December 2024  
**Version:** 1.0.0+1  
**Status:** 🚀 Emergency Flow Sprint (Week 1-4)  
**Strategic Focus:** Emergency → Transport → Facility (Wedge Flow)

---

## 🎯 Mindset Shift

**We are not building a healthcare app.**  
**We are an emergency-response company that uses Flutter and Firebase.**

This means:
- Reliability > Features
- Operational readiness > Code perfection
- Real emergencies > Demo scenarios
- Ministry data > User metrics
- Trust > Speed

**See [COMMITMENT.md](docs/COMMITMENT.md) for full commitment framework**

---

## 🎯 Mindset Shift

**We are not building a healthcare app.**  
**We are an emergency-response company that uses Flutter and Firebase.**

This means:
- Reliability > Features
- Operational readiness > Code perfection
- Real emergencies > Demo scenarios
- Ministry data > User metrics
- Trust > Speed

**See [COMMITMENT.md](docs/COMMITMENT.md) for full commitment framework**
