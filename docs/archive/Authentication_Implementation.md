# HeaLyri Authentication Implementation

This document outlines the implementation details of the HeaLyri authentication system, including security features, user experience enhancements, and role-based access control.

## Table of Contents
1. [Authentication Architecture](#authentication-architecture)
2. [Security Features](#security-features)
3. [User Experience Enhancements](#user-experience-enhancements)
4. [Role-Based Access Control](#role-based-access-control)
5. [Implementation Status](#implementation-status)
6. [Next Steps](#next-steps)

## Authentication Architecture

The HeaLyri authentication system is built on Firebase Authentication and uses a combination of Firebase Auth, Firestore, and Cloud Functions to provide a secure, scalable, and user-friendly authentication experience.

### Key Components

1. **Firebase Authentication**: Handles user authentication with email/password, Google, and Facebook sign-in methods.
2. **Firestore**: Stores user profile data and role information.
3. **Cloud Functions**: Manages custom claims for role-based access control and user verification.
4. **AuthService**: Client-side service that interfaces with Firebase Auth and Firestore.
5. **AuthWrapper**: Handles authentication state changes and routes users to appropriate screens.

### Authentication Flow

1. **User Registration**: Users sign up with email/password or social providers and select a role (patient, provider, driver).
2. **Email Verification**: Users must verify their email address before accessing the app.
3. **Role Verification**: Providers and drivers must be verified by administrators before accessing their respective dashboards.
4. **Authentication State Management**: The app listens to authentication state changes and routes users accordingly.

## Security Features

### Email Verification

- Email verification is sent automatically when a user signs up
- Users must verify their email address before accessing the app
- The app provides a dedicated email verification screen with:
  - Clear instructions
  - Option to resend verification email
  - Sign out option

Implementation:
```dart
// Send email verification
await userCredential.user!.sendEmailVerification();

// Check if email is verified
Future<bool> isEmailVerified() async {
  await currentUser?.reload();
  return currentUser?.emailVerified ?? false;
}
```

### Strong Password Requirements

Password requirements have been enhanced to improve security:

- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

Implementation:
```dart
// Password validation
if (value.length < 8) {
  return 'Password must be at least 8 characters';
}

if (!RegExp(r'[A-Z]').hasMatch(value)) {
  return 'Password must contain at least one uppercase letter';
}

if (!RegExp(r'[a-z]').hasMatch(value)) {
  return 'Password must contain at least one lowercase letter';
}

if (!RegExp(r'[0-9]').hasMatch(value)) {
  return 'Password must contain at least one number';
}

if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
  return 'Password must contain at least one special character';
}
```

### Password Reset

- Users can reset their password via the "Forgot Password?" link
- The app provides a user-friendly dialog for requesting password resets
- Success and error messages are displayed to guide the user

Implementation:
```dart
// Reset password
Future<void> resetPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}
```

## User Experience Enhancements

### Remember Me Option

- Users can choose to stay signed in between app sessions
- The app uses Firebase Auth persistence settings based on user preference

Implementation:
```dart
// Set persistence based on rememberMe option
if (rememberMe) {
  // Keep the user signed in even after browser/app restart
  await _auth.setPersistence(Persistence.LOCAL);
} else {
  // Clear user session when browser/app is closed
  await _auth.setPersistence(Persistence.SESSION);
}
```

### Social Authentication

- Users can sign in with Google and Facebook
- Social authentication is integrated with the role-based access control system
- New users are prompted to select a role

Implementation:
```dart
// Sign in with Google
Future<UserCredential> signInWithGoogle({required UserRole role}) async {
  // Google sign-in implementation
}

// Sign in with Facebook
Future<UserCredential> signInWithFacebook({required UserRole role}) async {
  // Facebook sign-in implementation
}
```

## Role-Based Access Control

### Custom Claims

Firebase Custom Claims are used to securely store user roles and verification status. This approach provides several advantages:

1. More secure than storing roles in Firestore alone
2. Reduces database reads
3. Prevents unauthorized role changes
4. Enables server-side validation of roles

Implementation:
```javascript
// Cloud Function to set custom claims
export const setUserClaims = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    // Set custom claims based on user role
    const customClaims = {
      role: role,
      isPatient: role === 'patient',
      isProvider: role === 'provider',
      isDriver: role === 'driver',
    };
    
    // Set custom user claims
    await admin.auth().setCustomUserClaims(userId, customClaims);
  });
```

### Role Verification

Providers and drivers must be verified by administrators before accessing their respective dashboards. This ensures that only legitimate healthcare providers and transportation partners can use the platform.

Implementation:
```javascript
// Cloud Function to verify special roles
export const verifySpecialRole = functionsV2.https.onCall(async (request) => {
  // Verify provider or driver account
  const updatedClaims = {
    ...currentClaims,
    isVerified: isVerified === true,
    verifiedAt: isVerified === true ? new Date().getTime() : null,
  };
  
  // Set the updated custom claims
  await admin.auth().setCustomUserClaims(userId, updatedClaims);
});
```

## Implementation Status

The following authentication features have been implemented:

✅ Firebase Authentication integration  
✅ Email/password authentication  
✅ Google and Facebook authentication  
✅ Role-based access control with custom claims  
✅ Email verification  
✅ Strong password requirements  
✅ Password reset functionality  
✅ Remember Me option  
✅ Role verification for providers and drivers  

## Next Steps

The following enhancements are planned for future implementation:

### 1. Biometric Authentication

- Implement fingerprint and face recognition login on supported devices
- Integrate with local authentication plugins
- Provide fallback options for devices without biometric capabilities

```dart
// Pseudocode for biometric authentication
Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  final bool canCheckBiometrics = await auth.canCheckBiometrics;
  
  if (canCheckBiometrics) {
    return await auth.authenticate(
      localizedReason: 'Authenticate to access your account',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
  
  return false;
}
```

### 2. Account Linking

- Allow users to link multiple authentication methods to a single account
- Implement a secure account linking flow
- Provide UI for managing linked accounts

```dart
// Pseudocode for account linking
Future<void> linkEmailPassword(String email, String password) async {
  final credential = EmailAuthProvider.credential(
    email: email,
    password: password,
  );
  
  await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
}
```

### 3. Multi-Factor Authentication (MFA)

- Implement SMS-based second factor authentication
- Allow users to enable/disable MFA
- Provide backup codes for account recovery

```dart
// Pseudocode for enabling MFA
Future<void> enableMFA(String phoneNumber) async {
  await FirebaseAuth.instance.currentUser?.multiFactor.getSession();
  // Complete MFA enrollment
}
```

### 4. Session Management

- Implement session timeout settings
- Allow administrators to view and manage active sessions
- Provide ability to force sign out from all devices

```dart
// Pseudocode for session management
Future<void> signOutAllDevices() async {
  await FirebaseAuth.instance.currentUser?.getIdToken(true);
  // Revoke refresh tokens
}
```

### 5. Authentication Analytics

- Track authentication success/failure rates
- Monitor suspicious activity
- Implement rate limiting for failed authentication attempts

```dart
// Pseudocode for authentication analytics
void logAuthEvent(String eventType, Map<String, dynamic> parameters) {
  FirebaseAnalytics.instance.logEvent(
    name: eventType,
    parameters: parameters,
  );
}
```

### 6. Comprehensive Testing

- Implement unit tests for authentication logic
- Add integration tests for authentication flows
- Create UI tests for authentication screens

```dart
// Pseudocode for authentication testing
void testSignIn() {
  // Test sign-in with valid credentials
  // Test sign-in with invalid credentials
  // Test sign-in with social providers
}
