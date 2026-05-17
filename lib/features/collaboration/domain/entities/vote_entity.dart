import 'package:equatable/equatable.dart';

class VoteEntity extends Equatable {
  final String sessionId;
  final String googlePlaceId;
  final String venueName;
  final String? participantName;
  final String vote;

  const VoteEntity({
    required this.sessionId,
    required this.googlePlaceId,
    required this.venueName,
    this.participantName,
    required this.vote,
  });

  @override
  List<Object?> get props => [
        sessionId,
        googlePlaceId,
        venueName,
        participantName,
        vote,
      ];
}
