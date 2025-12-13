# HeaLyri App Project Structure

Once Flutter is installed, you can create the project structure as outlined below. This structure follows the architecture defined in our planning documents.

## Creating the Project

After installing Flutter, run the following command to create a new Flutter project:

```bash
flutter create --org com.healyri healyri_app
cd healyri_app
```

## Project Structure

Modify the default Flutter project structure to match the following:

```
healyri_app/
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── lib/                     # Main Dart code
│   ├── config/              # App configuration
│   │   ├── app_config.dart  # Environment configuration
│   │   ├── routes.dart      # Navigation routes
│   │   └── theme.dart       # App theme
│   ├── models/              # Data models
│   │   ├── user_model.dart
│   │   ├── facility_model.dart
│   │   └── appointment_model.dart
│   ├── services/            # Business logic and API services
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   ├── screens/             # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── dashboard_screen.dart
│   │   ├── facilities/
│   │   │   ├── facility_list_screen.dart
│   │   │   └── facility_detail_screen.dart
│   │   └── appointments/
│   │       ├── appointment_list_screen.dart
│   │       ├── appointment_detail_screen.dart
│   │       └── appointment_booking_screen.dart
│   ├── widgets/             # Reusable UI components
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   └── loading_indicator.dart
│   │   ├── facility/
│   │   │   ├── facility_card.dart
│   │   │   └── service_list.dart
│   │   └── appointment/
│   │       ├── appointment_card.dart
│   │       └── time_slot_picker.dart
│   ├── utils/               # Utility functions
│   │   ├── validators.dart
│   │   ├── date_time_helpers.dart
│   │   └── constants.dart
│   └── main.dart            # Entry point
├── test/                    # Unit and widget tests
├── integration_test/        # Integration tests
├── assets/                  # Static assets
│   ├── images/
│   ├── fonts/
│   └── icons/
├── pubspec.yaml             # Dependencies
└── README.md                # Project documentation
```

## Firebase Setup

After creating the project structure, set up Firebase:

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your Flutter project:
   ```bash
   flutterfire configure --project=healyri
   ```

3. Initialize Firebase in your app by editing `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

## Dependencies

Update your `pubspec.yaml` file to include the necessary dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.15.0
  firebase_auth: ^4.7.2
  cloud_firestore: ^4.8.4
  firebase_storage: ^11.2.5
  firebase_messaging: ^14.6.5
  
  # State Management
  provider: ^6.0.5
  
  # UI
  flutter_svg: ^2.0.7
  cached_network_image: ^3.2.3
  intl: ^0.18.1
  
  # Utils
  url_launcher: ^6.1.12
  shared_preferences: ^2.2.0
  image_picker: ^1.0.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^2.0.2
```

## Initial Files

Here are some starter files to help you begin:

### lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'HeaLyri',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.initial,
        routes: AppRoutes.routes,
      ),
    );
  }
}
```

### lib/config/theme.dart

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryTeal = Color(0xFF26A69A);
  static const Color alertRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningAmber = Color(0xFFFFB300);
  static const Color darkGray = Color(0xFF424242);
  static const Color mediumGray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color white = Color(0xFFFFFFFF);

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkGray,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: darkGray,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: darkGray,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: darkGray,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: darkGray,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: mediumGray,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: white,
  );

  // Theme Data
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryTeal,
      error: alertRed,
    ),
    scaffoldBackgroundColor: lightGray,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      foregroundColor: darkGray,
      elevation: 4,
      titleTextStyle: heading3,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        textStyle: buttonText,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        textStyle: buttonText,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGray,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: primaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: alertRed),
      ),
      labelStyle: caption,
    ),
    cardTheme: CardTheme(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(8),
    ),
  );
}
```

### lib/config/routes.dart

```dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/facilities/facility_list_screen.dart';
import '../screens/facilities/facility_detail_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/appointments/appointment_booking_screen.dart';
import '../screens/appointments/appointment_detail_screen.dart';

class AppRoutes {
  static const String initial = '/login';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String facilityList = '/facilities';
  static const String facilityDetail = '/facility-detail';
  static const String appointmentList = '/appointments';
  static const String appointmentBooking = '/appointment-booking';
  static const String appointmentDetail = '/appointment-detail';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => LoginScreen(),
        register: (context) => RegisterScreen(),
        forgotPassword: (context) => ForgotPasswordScreen(),
        home: (context) => HomeScreen(),
        facilityList: (context) => FacilityListScreen(),
        facilityDetail: (context) => FacilityDetailScreen(),
        appointmentList: (context) => AppointmentListScreen(),
        appointmentBooking: (context) => AppointmentBookingScreen(),
        appointmentDetail: (context) => AppointmentDetailScreen(),
      };
}
```

## Next Steps

After setting up this structure:

1. Implement the basic models for User, Facility, and Appointment
2. Create the authentication screens and service
3. Implement the home screen with navigation
4. Build the facility directory and appointment booking features

This structure provides a solid foundation for implementing the HeaLyri app according to our architecture and design guidelines.
