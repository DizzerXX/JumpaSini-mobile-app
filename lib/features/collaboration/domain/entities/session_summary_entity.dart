import 'package:equatable/equatable.dart';

import '../../../../features/session/domain/entities/participant_entity.dart';
import '../../../../features/session/domain/entities/session_entity.dart';
import '../../../../features/venue/domain/entities/venue_entity.dart';
import 'vote_summary_entity.dart';
import 'voting_state_entity.dart';

class SessionSummaryEntity extends Equatable {
  final SessionEntity session;
  final List<ParticipantEntity> participants;
  final double? midpointLat;
  final double? midpointLng;
  final VenueEntity? confirmedVenue;
  final Map<String, VoteSummaryEntity> voteSummary;
  final VotingStateEntity? votingState;
  final Map<String, String> venueNames;
  final VenueEntity? bestVenue;
  final bool isComplete;
  final DateTime expiresAt;

  const SessionSummaryEntity({
    required this.session,
    required this.participants,
    this.midpointLat,
    this.midpointLng,
    this.confirmedVenue,
    this.voteSummary = const {},
    this.votingState,
    this.venueNames = const {},
    this.bestVenue,
    required this.isComplete,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [
        session,
        participants,
        midpointLat,
        midpointLng,
        confirmedVenue,
        voteSummary,
        votingState,
        venueNames,
        bestVenue,
        isComplete,
        expiresAt,
      ];
}
