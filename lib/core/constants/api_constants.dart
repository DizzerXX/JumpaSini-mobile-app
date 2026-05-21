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

  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
}
