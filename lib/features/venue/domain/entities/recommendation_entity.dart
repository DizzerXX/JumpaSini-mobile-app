import 'package:equatable/equatable.dart';

import 'participant_travel_summary.dart';
import 'venue_entity.dart';

class RecommendationEntity extends Equatable {
  final String sessionShortCode;
  final double midpointLat;
  final double midpointLng;
  final VenueEntity bestVenue;
  final List<ParticipantTravelSummary> participantSummary;
  final double fairnessScore;
  final String transportMode;
  final String venueType;
  final DateTime calculatedAt;

  const RecommendationEntity({
    required this.sessionShortCode,
    required this.midpointLat,
    required this.midpointLng,
    required this.bestVenue,
    required this.participantSummary,
    required this.fairnessScore,
    required this.transportMode,
    required this.venueType,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
        sessionShortCode,
        midpointLat,
        midpointLng,
        bestVenue,
        participantSummary,
        fairnessScore,
        transportMode,
        venueType,
        calculatedAt,
      ];
}
