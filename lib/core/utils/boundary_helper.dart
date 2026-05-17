class BoundaryHelper {
  BoundaryHelper._();

  static const double minLat = 2.6000;
  static const double maxLat = 3.9000;
  static const double minLng = 101.2000;
  static const double maxLng = 102.0000;

  static bool isWithinKLSelangor(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}
