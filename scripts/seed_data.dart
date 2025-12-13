import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';

// This script will seed your Firestore database with test users and data
// Run this script with: flutter run -d chrome scripts/seed_data.dart

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAkOfOBSmESry0ZvR2ZXvHD6zMrhSN1DnA",
      authDomain: "healyri-af36a.firebaseapp.com",
      projectId: "healyri-af36a",
      storageBucket: "healyri-af36a.appspot.com",
      messagingSenderId: "855143760278",
      appId: "1:855143760278:web:3a350c9a58812102691db7",
      measurementId: "G-MEASUREMENT_ID",
    ),
  );

  // Get Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // List of test users to create
  final List<Map<String, dynamic>> testUsers = [
    {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'role': 'patient',
      'photoURL': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'role': 'patient',
      'photoURL': 'https://randomuser.me/api/portraits/women/1.jpg',
    },
    {
      'name': 'Dr. Robert Johnson',
      'email': 'robert.johnson@example.com',
      'role': 'provider',
      'photoURL': 'https://randomuser.me/api/portraits/men/2.jpg',
    },
    {
      'name': 'Dr. Sarah Williams',
      'email': 'sarah.williams@example.com',
      'role': 'provider',
      'photoURL': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
  ];

  // Create test users
  for (var userData in testUsers) {
    try {
      // Create user with email and password
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: 'password123', // Default password for test users
      );

      // Update user profile
      await userCredential.user!.updateDisplayName(userData['name']);
      await userCredential.user!.updatePhotoURL(userData['photoURL']);

      // Store user data in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': userData['name'],
        'email': userData['email'],
        'role': userData['role'],
        'photoURL': userData['photoURL'],
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
      });

      print('Created user: ${userData['name']}');
    } catch (e) {
      print('Error creating user ${userData['name']}: $e');
    }
  }

  // Seed some test data for patients
  final patients = await firestore.collection('users').where('role', isEqualTo: 'patient').get();
  
  for (var patientDoc in patients.docs) {
    // Create some health records
    for (int i = 0; i < 5; i++) {
      await firestore.collection('health_records').add({
        'userId': patientDoc.id,
        'date': DateTime.now().subtract(Duration(days: i * 7)),
        'type': ['blood_pressure', 'heart_rate', 'weight', 'sleep'][Random().nextInt(4)],
        'value': Random().nextDouble() * 100,
        'notes': 'Test health record ${i + 1}',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Create some appointments
    final providers = await firestore.collection('users').where('role', isEqualTo: 'provider').get();
    if (providers.docs.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        final providerDoc = providers.docs[Random().nextInt(providers.docs.length)];
        await firestore.collection('appointments').add({
          'patientId': patientDoc.id,
          'providerId': providerDoc.id,
          'date': DateTime.now().add(Duration(days: i * 7)),
          'status': ['scheduled', 'completed', 'cancelled'][Random().nextInt(3)],
          'notes': 'Test appointment ${i + 1}',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  print('Data seeding completed!');
} 