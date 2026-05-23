import '../../../../features/session/data/models/participant_model.dart';
import '../../../../features/session/data/models/session_model.dart';
import '../../../../features/venue/data/models/venue_model.dart';
import '../../../../features/venue/domain/entities/venue_entity.dart';
import '../../domain/entities/session_summary_entity.dart';
import '../../domain/entities/voting_state_entity.dart';
import 'vote_summary_model.dart';

class SessionSummaryModel extends SessionSummaryEntity {
  const SessionSummaryModel({
    required super.session,
    required super.participants,
    super.midpointLat,
    super.midpointLng,
    super.confirmedVenue,
    super.voteSummary,
    super.votingState,
    super.venueNames,
    super.bestVenue,
    required super.isComplete,
    required super.expiresAt,
  });

  factory SessionSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final sessionJson = data['session'] as Map<String, dynamic>? ?? {};
    final session = SessionModel.fromJson(sessionJson);

    final participantsList = data['participants'] as List<dynamic>? ?? [];
    final participants = participantsList
        .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final midpointJson = data['midpoint'] as Map<String, dynamic>?;
    final midpointLat = (midpointJson?['lat'] as num?)?.toDouble();
    final midpointLng = (midpointJson?['lng'] as num?)?.toDouble();

    final confirmedJson = data['confirmed_venue'] as Map<String, dynamic>?;
    final confirmedVenue =
        confirmedJson != null ? _parseConfirmedVenue(confirmedJson) : null;

    final rawVotes = data['vote_summary'] as Map<String, dynamic>? ?? {};
    final voteSummary = VoteSummaryModel.mapFromJson(rawVotes);

    final votingStateJson = data['voting_state'] as Map<String, dynamic>?;
    final votingState =
        votingStateJson != null ? _parseVotingState(votingStateJson) : null;

    final recommendationJson = data['recommendation'] as Map<String, dynamic>?;
    final venueNames = _parseVenueNames(recommendationJson);
    final bestVenue = _parseBestVenue(recommendationJson);

    final isComplete = data['is_complete'] as bool? ?? false;
    final expiresAt = data['expires_at'] != null
        ? DateTime.parse(data['expires_at'] as String)
        : DateTime.now().add(const Duration(hours: 48));

    return SessionSummaryModel(
      session:       session,
      participants:  participants,
      midpointLat:   midpointLat,
      midpointLng:   midpointLng,
      confirmedVenue: confirmedVenue,
      voteSummary:   voteSummary,
      votingState:   votingState,
      venueNames:    venueNames,
      bestVenue:     bestVenue,
      isComplete:    isComplete,
      expiresAt:     expiresAt,
    );
  }

  static VotingStateEntity _parseVotingState(Map<String, dynamic> json) {
    return VotingStateEntity(
      active:               json['active'] as bool? ?? false,
      endsAt:               json['ends_at'] != null
                                ? DateTime.parse(json['ends_at'] as String)
                                : null,
      secondsRemaining:     (json['seconds_remaining'] as num?)?.toInt() ?? 0,
      winningVenue:         json['winning_venue'] as String?,
      votingConfirmedVenue: json['voting_confirmed_venue'] as String?,
    );
  }

  static VenueEntity? _parseBestVenue(Map<String, dynamic>? recommendation) {
    final bestVenueJson = recommendation?['best_venue'] as Map<String, dynamic>?;
    if (bestVenueJson == null) return null;
    try {
      return VenueModel.fromJson(bestVenueJson);
    } catch (_) {
      return null;
    }
  }

  static Map<String, String> _parseVenueNames(
    Map<String, dynamic>? recommendation,
  ) {
    final venues = recommendation?['venues'] as List<dynamic>?;
    if (venues == null) return const {};
    final result = <String, String>{};
    for (final v in venues) {
      if (v is Map<String, dynamic>) {
        final placeId = v['place_id'] as String?;
        final name = v['name'] as String?;
        if (placeId != null && name != null) result[placeId] = name;
      }
    }
    return result;
  }

  static VenueEntity _parseConfirmedVenue(Map<String, dynamic> json) {
    final placeId = json['google_place_id'] as String? ?? '';
    return VenueEntity(
      placeId:         placeId,
      name:            json['name'] as String? ?? '',
      address:         json['address'] as String? ?? '',
      lat:             (json['latitude'] as num?)?.toDouble() ?? 0.0,
      lng:             (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type:            '',
      rating:          (json['google_rating'] as num?)?.toDouble(),
      isHalal:         json['is_halal'] as bool?,
      isHalalVerified: json['is_halal_verified'] as bool? ?? false,
      distanceMeters:  0,
      googleMapsUrl:   'https://www.google.com/maps/search/?api=1&query=${(json['latitude'] as num?)?.toDouble() ?? 0.0},${(json['longitude'] as num?)?.toDouble() ?? 0.0}&query_place_id=$placeId',
      source:          'confirmed',
    );
  }
}
