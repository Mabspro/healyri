import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';
import '../core/logger.dart';

/// Service for managing appointments
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'appointments';

  /// Get the next upcoming appointment for the current user
  /// Returns null if no upcoming appointments exist
  Future<Appointment?> getUpcomingAppointment() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.w('Cannot get appointments: user not authenticated');
        return null;
      }

      final now = DateTime.now();
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('patientId', isEqualTo: user.uid)
          .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
          .where('status', whereIn: ['pending', 'confirmed'])
          .orderBy('dateTime', descending: false)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLogger.d('No upcoming appointments found for user: ${user.uid}');
        return null;
      }

      final appointment = Appointment.fromFirestore(querySnapshot.docs.first);
      AppLogger.d('Found upcoming appointment: ${appointment.id}');
      return appointment;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get upcoming appointment', e, stackTrace);
      // If it's an index error, log it but don't crash
      if (e.toString().contains('index')) {
        AppLogger.w('⚠️ Firestore index may be missing. Create composite index: patientId (ASC), dateTime (ASC), status (ASC)');
      }
      return null;
    }
  }

  /// Stream of upcoming appointments for the current user
  Stream<Appointment?> streamUpcomingAppointment() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    final now = DateTime.now();

    return _firestore
        .collection(_collectionName)
        .where('patientId', isEqualTo: user.uid)
        .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
        .where('status', whereIn: ['pending', 'confirmed'])
        .orderBy('dateTime', descending: false)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          try {
            return Appointment.fromFirestore(snapshot.docs.first);
          } catch (e) {
            AppLogger.e('Error parsing appointment', e);
            return null;
          }
        });
  }

  /// Get all appointments for the current user
  Stream<List<Appointment>> getUserAppointments() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collectionName)
        .where('patientId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Appointment.fromFirestore(doc);
                } catch (e) {
                  AppLogger.e('Error parsing appointment ${doc.id}', e);
                  return null;
                }
              })
              .whereType<Appointment>()
              .toList();
        });
  }

  /// Get today's appointments for a provider/facility
  Future<int> getTodayAppointmentsCount({String? facilityId, String? providerId}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      Query query = _firestore
          .collection(_collectionName)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['pending', 'confirmed']);

      if (facilityId != null) {
        query = query.where('facilityId', isEqualTo: facilityId);
      } else if (providerId != null) {
        query = query.where('providerId', isEqualTo: providerId);
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get today appointments count', e, stackTrace);
      return 0;
    }
  }

  /// Get pending appointments count for a provider/facility
  Future<int> getPendingAppointmentsCount({String? facilityId, String? providerId}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'pending');

      if (facilityId != null) {
        query = query.where('facilityId', isEqualTo: facilityId);
      } else if (providerId != null) {
        query = query.where('providerId', isEqualTo: providerId);
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get pending appointments count', e, stackTrace);
      return 0;
    }
  }

  /// Get today's appointments for a provider/facility (stream)
  Stream<List<Appointment>> streamTodayAppointments({String? facilityId, String? providerId}) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    Query query = _firestore
        .collection(_collectionName)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', whereIn: ['pending', 'confirmed'])
        .orderBy('dateTime', descending: false);

    if (facilityId != null) {
      query = query.where('facilityId', isEqualTo: facilityId);
    } else if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Appointment.fromFirestore(doc);
            } catch (e) {
              AppLogger.e('Error parsing appointment ${doc.id}', e);
              return null;
            }
          })
          .whereType<Appointment>()
          .toList();
    });
  }

  /// Create a new appointment
  Future<Appointment> createAppointment({
    required String facilityId,
    required String facilityName,
    required DateTime dateTime,
    String? providerId,
    String? providerName,
    String? serviceType,
    int? duration,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create appointment');
      }

      // Get user name
      String? patientName;
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          patientName = userDoc.data()?['name'] as String?;
        }
      } catch (e) {
        AppLogger.w('Could not fetch user name: $e');
      }

      final appointment = Appointment(
        id: '', // Will be generated by Firestore
        patientId: user.uid,
        patientName: patientName,
        facilityId: facilityId,
        facilityName: facilityName,
        providerId: providerId,
        providerName: providerName,
        serviceType: serviceType,
        dateTime: dateTime,
        duration: duration ?? 30, // Default 30 minutes
        status: AppointmentStatus.pending,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_collectionName)
          .add(appointment.toFirestore());

      AppLogger.i('Appointment created with ID: ${docRef.id}');
      return appointment.copyWith(id: docRef.id);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create appointment', e, stackTrace);
      rethrow;
    }
  }
}

