class ApiConstants {
  ApiConstants._();

  // 10.0.2.2 is Android emulator's alias for host machine localhost.
  // Replace with your LAN IP (e.g. 192.168.x.x) for physical device testing.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

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

  // Add your Google Maps / Places API key here.
  // Enable: Maps SDK for Android, Places API in Google Cloud Console.
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
}
