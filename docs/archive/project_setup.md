# HeaLyri: Project Setup Guide

This document provides comprehensive instructions for setting up the development environment and initializing the HeaLyri project.

## Development Environment Setup

### Prerequisites

- [Git](https://git-scm.com/downloads)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, Mac only)
- [VS Code](https://code.visualstudio.com/) (recommended IDE)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Node.js](https://nodejs.org/) (LTS version)

### VS Code Extensions

- Flutter extension
- Dart extension
- Firebase extension
- Mermaid Preview
- GitLens

## 1. Flutter SDK Installation

### Download Flutter SDK

1. Download the Flutter SDK from the official website: https://flutter.dev/docs/get-started/install/windows
2. Extract the downloaded zip file to a location on your computer (e.g., `C:\Users\username\healyri\flutter`)
   - Make sure the `flutter` folder is directly under the healyri project directory
   - This will create the structure: `C:\Users\username\healyri\flutter\bin\flutter.bat`

### Add Flutter to PATH

1. Open the Start menu and search for "Environment Variables"
2. Click on "Edit the system environment variables"
3. Click the "Environment Variables..." button
4. Under "User variables", find the "Path" variable, select it, and click "Edit"
5. Click "New" and add the path to the Flutter bin directory (e.g., `C:\Users\username\healyri\flutter\bin`)
6. Click "OK" to save

### Verify Installation

1. Close and reopen any existing Command Prompt or PowerShell windows
2. Open a new terminal and run:
   ```
   flutter doctor -v
   ```
3. This command checks your environment and displays a report of the status of your Flutter installation

## 2. Android Studio & SDK Setup

### Install Android Studio

1. Download and install Android Studio from: https://developer.android.com/studio
2. During installation, make sure to select:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device
3. After installation, open Android Studio and go through the setup wizard

### Install Flutter and Dart Plugins

1. Open Android Studio
2. Go to File > Settings > Plugins
3. Search for "Flutter" and install it (this will also install the Dart plugin)
4. Restart Android Studio

### Configure Android SDK

1. Open Android Studio
2. Go to File > Settings > Appearance & Behavior > System Settings > Android SDK
3. Make sure the latest Android SDK is installed
4. Note the Android SDK Location (e.g., `C:\Users\username\AppData\Local\Android\Sdk`)

### Accept Android Licenses

Run the following command to accept the Android licenses:

```
flutter doctor --android-licenses
```

## 3. Create and Set Up Emulator

1. Launch Android Studio
2. Click on "More Actions" or "Configure" > "AVD Manager"
3. Click on "Create Virtual Device"
4. Select a device definition (e.g., Pixel 6)
5. Select a system image (e.g., Android 13)
6. Configure the AVD with desired options
7. Click "Finish" to create the emulator
8. Start the emulator by clicking the play button in the AVD Manager

## 4. Project Initialization

### Clone the Repository

```bash
git clone https://github.com/healyri/healyri-app.git
cd healyri-app
```

### Configure pubspec.yaml

Create or update the pubspec.yaml file in the project root with the following content:

```yaml
name: healyri
description: A comprehensive healthcare platform for Zambia

# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none'

# The following defines the version and build number for your application.
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.0.5
  http: ^1.1.0
  shared_preferences: ^2.2.0
  intl: ^0.18.1
  url_launcher: ^6.1.12
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.2

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/logo/
    - assets/images/icons/
    - assets/images/illustrations/
```

### Install Dependencies

Run the following command to fetch the project dependencies:

```
flutter pub get
```

## 5. Firebase Project Setup

### Create a new Firebase project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter "HeaLyri" as the project name
4. Enable Google Analytics (recommended)
5. Choose or create a Google Analytics account
6. Click "Create project"

### Configure Firebase for Flutter

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure --project=healyri
```

### Enable Firebase Services

In the Firebase Console, enable the following services:

1. **Authentication**
   - Enable Email/Password authentication
   - Enable Phone Number authentication
   - (Optional) Enable Google Sign-In

2. **Firestore Database**
   - Create database in production mode
   - Set up initial security rules

3. **Storage**
   - Set up initial security rules

4. **Functions**
   - Upgrade to Blaze plan (pay-as-you-go)
   - Set up Node.js environment

## 6. Initial Project Structure

Create the following directory structure:

```
lib/
├── config/
│   ├── app_config.dart
│   ├── routes.dart
│   └── theme.dart
├── models/
│   ├── user_model.dart
│   ├── facility_model.dart
│   └── appointment_model.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── dashboard_screen.dart
│   ├── facilities/
│   │   ├── facility_list_screen.dart
│   │   └── facility_detail_screen.dart
│   └── appointments/
│       ├── appointment_list_screen.dart
│       ├── appointment_detail_screen.dart
│       └── appointment_booking_screen.dart
├── widgets/
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_indicator.dart
│   ├── facility/
│   │   ├── facility_card.dart
│   │   └── service_list.dart
│   └── appointment/
│       ├── appointment_card.dart
│       └── time_slot_picker.dart
├── utils/
│   ├── validators.dart
│   ├── date_time_helpers.dart
│   └── constants.dart
└── main.dart
```

## 7. Firebase Cloud Functions Setup

```bash
# Initialize Firebase Functions
firebase init functions

# Choose JavaScript or TypeScript
# Select ESLint
# Install dependencies with npm
```

Create initial Cloud Functions structure:

```
functions/
├── src/
│   ├── auth/
│   │   └── user_triggers.js
│   ├── appointments/
│   │   ├── appointment_triggers.js
│   │   └── notifications.js
│   └── payments/
│       └── payment_handlers.js
├── index.js
└── package.json
```

## 8. Set Up CI/CD with GitHub Actions

Create `.github/workflows/main.yml`:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --debug
      - uses: actions/upload-artifact@v3
        with:
          name: debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
```

## 9. Build and Run the App

### Run on Chrome

```
flutter run -d chrome
```

### Run on Android Emulator

First, make sure your emulator is running, then:

```
flutter run
```

## 10. Troubleshooting

### Common Issues and Solutions

1. **Flutter command not found**
   - Ensure Flutter is added to your PATH
   - Try restarting your terminal or IDE

2. **Android SDK not found**
   - Make sure Android Studio is installed
   - Configure the Android SDK path in Flutter:
     ```
     flutter config --android-sdk <path-to-your-sdk>
     ```

3. **No devices available**
   - Ensure your emulator is running
   - Check if your device is connected and has USB debugging enabled
   - Run `flutter devices` to see available devices

4. **Dart SDK is not configured**
   - The Dart SDK comes with Flutter, so make sure Flutter is properly installed
   - If using VS Code, install the Dart and Flutter extensions

5. **Missing asset files**
   - Ensure all asset directories exist
   - Check that pubspec.yaml correctly lists all asset directories
   - Run `flutter pub get` after updating pubspec.yaml

## Development Workflow

### Git Workflow

1. Create feature branches from `develop`
2. Make changes and commit regularly
3. Push to remote and create a pull request
4. After review, merge into `develop`
5. Periodically merge `develop` into `main` for releases

### Code Style

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and use the following tools:

```bash
# Format code
flutter format .

# Analyze code
flutter analyze
```

### Testing

Write tests for all critical functionality:

```bash
# Run tests
flutter test
```

## Deployment

### Android

1. Configure `android/app/build.gradle` with your app details
2. Create a keystore for signing the app
3. Build the release APK:
   ```bash
   flutter build apk --release
   ```

### iOS (Mac only)

1. Configure `ios/Runner/Info.plist` with your app details
2. Set up certificates and provisioning profiles in Xcode
3. Build the release IPA:
   ```bash
   flutter build ios --release
   ```

## Initial Development Tasks

### 1. Configure App Theme

Edit `lib/config/theme.dart` to define the app's color scheme, typography, and component styles.

### 2. Set Up Firebase Authentication

Implement basic authentication flows in the auth service and screens.

### 3. Create Data Models

Define the core data models (User, Facility, Appointment) with Firestore serialization.

### 4. Implement Basic Navigation

Set up the app's navigation structure using Flutter's Navigator 2.0 or a routing package like go_router.

### 5. Create Mock Data

Populate Firestore with sample data for development:
- Sample healthcare facilities
- Test user accounts
- Example appointments

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
- [Firestore Data Modeling Guide](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Flutter State Management Options](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)

## Next Steps

After completing the initial setup:

1. Familiarize yourself with the project structure
2. Review the existing code in the lib directory
3. Set up version control (Git) if not already done
4. Configure Firebase for backend services
5. Begin implementing features according to the project roadmap
