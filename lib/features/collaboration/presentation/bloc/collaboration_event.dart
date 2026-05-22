import 'package:equatable/equatable.dart';

abstract class CollaborationEvent extends Equatable {
  const CollaborationEvent();

  @override
  List<Object?> get props => [];
}

class CastVoteEvent extends CollaborationEvent {
  final String shortCode;
  final String placeId;
  final String venueName;
  final String? participantName;
  final String vote;

  const CastVoteEvent({
    required this.shortCode,
    required this.placeId,
    required this.venueName,
    this.participantName,
    required this.vote,
  });

  @override
  List<Object?> get props => [shortCode, placeId, venueName, participantName, vote];
}

class GetVotesEvent extends CollaborationEvent {
  final String shortCode;

  const GetVotesEvent(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}

class ConfirmVenueEvent extends CollaborationEvent {
  final String shortCode;
  final String placeId;

  const ConfirmVenueEvent({required this.shortCode, required this.placeId});

  @override
  List<Object?> get props => [shortCode, placeId];
}

class GetSessionSummaryEvent extends CollaborationEvent {
  final String shortCode;
  final bool silent;

  const GetSessionSummaryEvent(this.shortCode, {this.silent = false});

  @override
  List<Object?> get props => [shortCode];
}
