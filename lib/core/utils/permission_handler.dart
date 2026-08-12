import 'package:geolocator/geolocator.dart';

class LocationPermissionHandler {
  /// Throws geolocator's [LocationServiceDisabledException] when the device's
  /// location service (GPS) is switched off. That is distinct from a permission
  /// denial and needs a different remedy — opening app settings does not help,
  /// the user has to enable location services themselves.
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
