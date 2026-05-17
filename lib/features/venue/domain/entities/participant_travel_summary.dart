import 'package:equatable/equatable.dart';

import 'travel_time.dart';

class ParticipantTravelSummary extends Equatable {
  final String participantId;
  final String name;
  final TravelTime? travelTimeToBest;
  final String startingAddress;

  const ParticipantTravelSummary({
    required this.participantId,
    required this.name,
    this.travelTimeToBest,
    required this.startingAddress,
  });

  @override
  List<Object?> get props => [
        participantId,
        name,
        travelTimeToBest,
        startingAddress,
      ];
}
