import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow,
}

class Appointment {
  final String id;
  final String patientId;
  final String? patientName;
  final String facilityId;
  final String facilityName;
  final String? providerId;
  final String? providerName;
  final String? serviceType;
  final DateTime dateTime;
  final int? duration; // in minutes
  final AppointmentStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.facilityId,
    required this.facilityName,
    this.providerId,
    this.providerName,
    this.serviceType,
    required this.dateTime,
    this.duration,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] as String,
      patientName: data['patientName'] as String?,
      facilityId: data['facilityId'] as String,
      facilityName: data['facilityName'] as String,
      providerId: data['providerId'] as String?,
      providerName: data['providerName'] as String?,
      serviceType: data['serviceType'] as String?,
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      duration: data['duration'] as int?,
      status: _parseStatus(data['status'] as String? ?? 'pending'),
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'] as String))
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(data['updatedAt'] as String))
          : null,
    );
  }

  static AppointmentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no-show':
      case 'no_show':
      case 'noshow':
        return AppointmentStatus.noShow;
      case 'pending':
      default:
        return AppointmentStatus.pending;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      if (patientName != null) 'patientName': patientName,
      'facilityId': facilityId,
      'facilityName': facilityName,
      if (providerId != null) 'providerId': providerId,
      if (providerName != null) 'providerName': providerName,
      if (serviceType != null) 'serviceType': serviceType,
      'dateTime': Timestamp.fromDate(dateTime),
      if (duration != null) 'duration': duration,
      'status': status.toString().split('.').last,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? facilityId,
    String? facilityName,
    String? providerId,
    String? providerName,
    String? serviceType,
    DateTime? dateTime,
    int? duration,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceType: serviceType ?? this.serviceType,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

