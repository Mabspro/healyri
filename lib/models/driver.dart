import 'package:cloud_firestore/cloud_firestore.dart';

/// Driver status
enum DriverStatus {
  available,
  onTrip,
  offline,
}

/// Driver model
class Driver {
  final String id;
  final String userId;
  final String? name;
  final String? vehicleType;
  final String? vehicleNumber;
  final DriverStatus status;
  final GeoPoint? currentLocation;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Driver({
    required this.id,
    required this.userId,
    this.name,
    this.vehicleType,
    this.vehicleNumber,
    this.status = DriverStatus.available,
    this.currentLocation,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Driver from Firestore document
  factory Driver.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Driver(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String?,
      vehicleType: data['vehicleType'] as String?,
      vehicleNumber: data['vehicleNumber'] as String?,
      status: DriverStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => DriverStatus.offline,
      ),
      currentLocation: data['currentLocation'] as GeoPoint?,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Driver to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (name != null) 'name': name,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      'status': status.toString().split('.').last,
      if (currentLocation != null) 'currentLocation': currentLocation,
      'isVerified': isVerified,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}

