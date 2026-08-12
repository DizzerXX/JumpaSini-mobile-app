const bool _isProduction = bool.fromEnvironment('dart.vm.product');

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = _isProduction
      ? 'https://jumpasini-backend.onrender.com/api/v1'
      : 'http://10.0.2.2:8000/api/v1';

  static const String webAppUrl = _isProduction
      ? 'https://jumpasini-dashboard.onrender.com'
      : 'http://localhost:4200';

  static const String sessions = '/sessions';

  static String sessionByCode(String code) => '/sessions/$code';

  static String participants(String code) => '/sessions/$code/participants';

  static String participantById(String code, String participantId) =>
      '/sessions/$code/participants/$participantId';

  static String midpoint(String code) => '/sessions/$code/midpoint';
  static String venues(String code) => '/sessions/$code/venues';
  static String recommendation(String code) => '/sessions/$code/recommendation';
  static String halalReport(String placeId) => '/venues/$placeId/halal-report';
  static String votes(String code) => '/sessions/$code/votes';
  static String confirm(String code) => '/sessions/$code/confirm';
  static String summary(String code) => '/sessions/$code/summary';
  static String weather(String code) => '/sessions/$code/weather';
  static String votingStart(String code) => '/sessions/$code/voting/start';

  // ─── Places proxy ──────────────────────────────────────────────────────────
  // Address lookups go through the backend, which owns the Google key and caches
  // results. No Places key ships in this app.
  static const String placesAutocomplete = '/places/autocomplete';
  static const String placesReverseGeocode = '/places/reverse-geocode';

  static String placeDetails(String placeId) => '/places/$placeId';
}
