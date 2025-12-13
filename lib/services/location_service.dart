import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/logger.dart';

/// Service for getting user location
class LocationService {
  /// Get current location and return as GeoPoint
  /// Returns null if location cannot be determined
  Future<GeoPoint?> getCurrentLocation() async {
    try {
      AppLogger.i('Requesting location permissions');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.w('Location services are disabled');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.w('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.w('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      AppLogger.i('Getting current position');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      AppLogger.i(
        'Location obtained: ${position.latitude}, ${position.longitude}',
      );

      return GeoPoint(position.latitude, position.longitude);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get location', e, stackTrace);
      // Don't show error dialog here - let caller handle it
      return null;
    }
  }

  /// Get last known location (cached)
  Future<GeoPoint?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return GeoPoint(position.latitude, position.longitude);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get last known location', e, stackTrace);
      return null;
    }
  }
}

