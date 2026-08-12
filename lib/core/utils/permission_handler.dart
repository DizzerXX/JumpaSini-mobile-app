import 'package:geolocator/geolocator.dart';

/// Thrown by [LocationPermissionHandler.requestLocationPermission] when the
/// permission is granted but the device's location service (GPS) is off —
/// distinct from a permission denial, since `openAppSettings()` won't help here.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

class LocationPermissionHandler {
  static Future<bool> requestLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<bool> isGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<bool> isPermanentlyDenied() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Whether the device's location service (GPS) is on at all — independent of
  /// whether this app has been granted permission to use it.
  static Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }
}
