import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/logger.dart';

enum UserRole {
  patient,
  provider,
  driver,
  admin,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserRole role,
    required String name,
  }) async {
    try {
      AppLogger.i('Starting email signup process for $email with role $role');
      
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      AppLogger.i('User created successfully with ID: ${userCredential.user!.uid}');

      // Get the user ID
      final uid = userCredential.user!.uid;

      // Set the user's display name
      await userCredential.user!.updateDisplayName(name);
      AppLogger.d('Display name set to: $name');

      // Send email verification
      await userCredential.user!.sendEmailVerification();
      AppLogger.i('Verification email sent');

      // Store user data in Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role.toString().split('.').last, // Convert enum to string
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
        'isVerified': role == UserRole.patient, // Patients are auto-verified
      });
      
      AppLogger.i('User data stored in Firestore');

      return userCredential;
    } catch (e, stackTrace) {
      AppLogger.e('Error during email signup', e, stackTrace);
      rethrow;
    }
  }
  
  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      // Reload user to get the latest email verification status
      await currentUser?.reload();
      return currentUser?.emailVerified ?? false;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking email verification', e, stackTrace);
      return false;
    }
  }
  
  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error sending email verification', e, stackTrace);
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Set persistence based on rememberMe option
      if (rememberMe) {
        // Keep the user signed in even after browser/app restart
        await _auth.setPersistence(Persistence.LOCAL);
      } else {
        // Clear user session when browser/app is closed
        await _auth.setPersistence(Persistence.SESSION);
      }
      
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role - first checks custom claims, then falls back to Firestore
  Future<UserRole?> getUserRole() async {
    try {
      if (currentUser == null) return null;
      
      // Force token refresh to get the latest custom claims
      await currentUser!.getIdTokenResult(true);
      
      // Get the ID token result which contains custom claims
      final idTokenResult = await currentUser!.getIdTokenResult();
      final claims = idTokenResult.claims;
      
      // Check if role is in custom claims
      if (claims != null && claims['role'] != null) {
        final roleStr = claims['role'] as String;
        
        switch (roleStr) {
          case 'patient':
            return UserRole.patient;
          case 'provider':
            return UserRole.provider;
          case 'driver':
            return UserRole.driver;
          case 'admin':
            return UserRole.admin;
          default:
            // Fall through to check Firestore
            break;
        }
      }
      
      // If no role in custom claims, check Firestore as fallback
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      
      if (!doc.exists) return null;
      
      final roleStr = doc.data()?['role'] as String?;
      
      if (roleStr == null) return null;
      
      switch (roleStr) {
        case 'patient':
          return UserRole.patient;
        case 'provider':
          return UserRole.provider;
        case 'driver':
          return UserRole.driver;
        case 'admin':
          return UserRole.admin;
        default:
          return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error getting user role', e, stackTrace);
      return null;
    }
  }
  
  // Check if the user is verified (for providers and drivers)
  Future<bool> isUserVerified() async {
    try {
      if (currentUser == null) return false;
      
      // Force token refresh to get the latest custom claims
      await currentUser!.getIdTokenResult(true);
      
      // Get the ID token result which contains custom claims
      final idTokenResult = await currentUser!.getIdTokenResult();
      final claims = idTokenResult.claims;
      
      // Check if isVerified is in custom claims
      if (claims != null && claims['isVerified'] != null) {
        return claims['isVerified'] as bool;
      }
      
      // If not in claims, check Firestore
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      
      if (!doc.exists) return false;
      
      // Admin is always verified
      final roleStr = doc.data()?['role'] as String?;
      if (roleStr == 'admin') return true;
      
      return doc.data()?['isVerified'] as bool? ?? false;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking verification status', e, stackTrace);
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) return;

      // Update auth profile
      await currentUser!.updateDisplayName(name);
      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      // Update Firestore profile
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoURL != null) updates['photoURL'] = photoURL;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser!.uid).update(updates);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<UserCredential> signInWithGoogle({required UserRole role}) async {
    try {
      AppLogger.i('Starting Google sign-in process with role: $role');
      
      // Initialize Google Sign In
      // For web, the client ID must be set in web/index.html meta tag
      // For mobile, we can optionally pass it here, but it's usually in google-services.json
      // Note: Only using 'email' scope to avoid requiring People API
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email', // Only email scope - avoids People API requirement
        ],
        // Client ID for web (also set in web/index.html meta tag)
        // For mobile platforms, this is optional as it's in google-services.json
        clientId: kIsWeb 
            ? '855143760278-hj7ivko8g5fq32aeo90u2j37lt3b7g1s.apps.googleusercontent.com'
            : null,
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        AppLogger.w('Google sign-in was cancelled by the user');
        throw FirebaseAuthException(
          code: 'sign-in-cancelled',
          message: 'Sign in was cancelled by the user.',
        );
      }
      
      AppLogger.d('Google sign-in successful, getting authentication details');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      AppLogger.d('Google authentication details obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      AppLogger.d('Firebase credential created from Google auth');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      AppLogger.i('Firebase sign-in successful with Google credential');

      // Get the user ID
      final uid = userCredential.user!.uid;
      
      AppLogger.d('User ID: $uid');

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        AppLogger.i('Creating new user doc. Role: $role, UID: $uid');
        
        final userData = {
          'name': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'role': role.toString().split('.').last,
          'createdAt': DateTime.now().toIso8601String(),
          'isVerified': role == UserRole.patient || role == UserRole.admin,
        };
        
        AppLogger.d('User Data Payload (Simplified): $userData');

        // Create new user document
        try {
          // We use a short timeout so we don't block the user from signing in if Firestore is slow
          // Since persistence is enabled (or should be), this usually completes instantly.
          await _firestore.collection('users').doc(uid).set(userData)
              .timeout(const Duration(seconds: 10));
              
          AppLogger.i('New user document created in Firestore');
        } catch (e) {
          // If writing to Firestore fails (e.g. offline, permission), we STILL want to allow the user to sign in.
          // The data might sync later or be lost, but blocking sign-in is worse.
          AppLogger.w('⚠️ Could not create user document in Firestore (continuing anyway): $e');
        }
      } else {
        AppLogger.d('User document already exists in Firestore');
      }

      return userCredential;
    } catch (e, stackTrace) {
      AppLogger.e('Error during Google sign-in', e, stackTrace);
      rethrow;
    }
  }
  
  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook({required UserRole role}) async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        throw FirebaseAuthException(
          code: 'facebook-sign-in-failed',
          message: 'Facebook sign in failed. Please try again.',
        );
      }
      
      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );
      
      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser) {
        // Store user data in Firestore for new users
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': role.toString().split('.').last,
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
