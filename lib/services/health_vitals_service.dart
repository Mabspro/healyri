import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

class HealthVitals {
  final int? heartRate; // bpm
  final int? steps;
  final double? sleepHours;
  final DateTime? lastUpdated;

  HealthVitals({
    this.heartRate,
    this.steps,
    this.sleepHours,
    this.lastUpdated,
  });

  factory HealthVitals.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return HealthVitals();
    }

    return HealthVitals(
      heartRate: data['heartRate'] as int?,
      steps: data['steps'] as int?,
      sleepHours: data['sleepHours'] != null 
          ? (data['sleepHours'] is int 
              ? (data['sleepHours'] as int).toDouble()
              : data['sleepHours'] as double?)
          : null,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] is Timestamp
              ? (data['lastUpdated'] as Timestamp).toDate()
              : DateTime.parse(data['lastUpdated'] as String))
          : null,
    );
  }
}

/// Service for managing health vitals
class HealthVitalsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the latest health vitals for the current user
  /// Returns HealthVitals with null values if no data exists
  Future<HealthVitals> getLatestVitals() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.w('Cannot get vitals: user not authenticated');
        return HealthVitals();
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('vitals')
          .doc('latest')
          .get();

      if (!doc.exists) {
        AppLogger.d('No health vitals found for user: ${user.uid}');
        return HealthVitals();
      }

      return HealthVitals.fromFirestore(doc);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get health vitals', e, stackTrace);
      return HealthVitals();
    }
  }

  /// Stream of latest health vitals for the current user
  Stream<HealthVitals> streamLatestVitals() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(HealthVitals());
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vitals')
        .doc('latest')
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return HealthVitals();
          }
          try {
            return HealthVitals.fromFirestore(doc);
          } catch (e) {
            AppLogger.e('Error parsing health vitals', e);
            return HealthVitals();
          }
        });
  }
}

