class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'JumpaSini';
  static const String tagline = 'Find the perfect meetup spot for everyone';

  // Home
  static const String startMeetup = 'Start a Meetup';
  static const String joinMeetup = 'Join a Meetup';
  static const String enterSessionCode = 'Enter session code';
  static const String joinSession = 'Join Session';
  static const String sessionCodeHint = 'e.g. AB3X9QTZ';

  // Add location page
  static const String setupMeetup = 'Setup Meetup';
  static const String howWillYouTravel = 'How will everyone travel?';
  static const String car = 'Car';
  static const String publicTransport = 'Public Transport';
  static const String whatAreYouLookingFor = 'What are you looking for?';
  static const String halalOnly = 'Halal only';
  static const String next = 'Next';

  // Venue types
  static const String mall = 'Mall';
  static const String restaurant = 'Restaurant';
  static const String cafe = 'Cafe';
  static const String park = 'Park';
  static const String beach = 'Beach';
  static const String waterfall = 'Waterfall';
  static const String river = 'River';

  // Add participants page
  static const String addParticipants = 'Add Locations';
  static const String addParticipantsSubtitle =
      'Add your location to start. Share the code for others to join.';
  static const String yourName = 'Your name (optional)';
  static const String searchLocation = 'Search location in KL/Selangor...';
  static const String useCurrentLocation = 'Use my current location';
  static const String addParticipant = 'Add to list';
  static const String findMeetupSpot = 'Find Meetup Spot';
  static const String participantsCount = 'participants added';
  static const String minParticipants =
      'Add your location to start. Share the code for others to join.';
  static const String waitingForOthers = 'Waiting for friends to join...';
  static const String recalculatingSpots = 'Recalculating best spots...';
  static const String maxParticipants = 'Maximum 6 participants reached';
  static const String currentLocationLabel = 'Current Location';

  // Session page
  static const String sessionCode = 'Session Code';
  static const String shareCode = 'Share this code with your friends';
  static const String calculatingSpot = 'Calculating best meetup spot...';
  static const String participants = 'Participants';

  // Errors
  static const String addressRequired = 'Please enter or search for an address';
  static const String nameTooLong = 'Name must be 100 characters or less';
  static const String addressTooLong = 'Address must be 255 characters or less';
  static const String locationOutsideBoundary =
      'Location must be within Klang Valley (KL/Selangor)';
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Something went wrong. Please try again.';
  static const String sessionNotFound = 'Session not found or has expired.';
  static const String sessionFull = 'This session already has 6 participants.';
  static const String locationPermissionDenied =
      'Location permission denied. Please enable it in settings.';
  static const String locationUnavailable =
      'Could not get your current location. Please try again.';
  static const String sessionCodeRequired = 'Please enter a session code.';

  // Validation
  static const String fieldRequired = 'This field is required';
}
