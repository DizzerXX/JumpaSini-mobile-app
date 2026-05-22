import 'package:equatable/equatable.dart';

import '../../domain/entities/session_summary_entity.dart';
import '../../domain/entities/vote_summary_entity.dart';

abstract class CollaborationState extends Equatable {
  const CollaborationState();

  @override
  List<Object?> get props => [];
}

class CollaborationInitial extends CollaborationState {
  const CollaborationInitial();
}

class CollaborationLoading extends CollaborationState {
  const CollaborationLoading();
}

class VoteCast extends CollaborationState {
  final Map<String, VoteSummaryEntity> voteSummary;
  final String myVote;

  const VoteCast({required this.voteSummary, required this.myVote});

  @override
  List<Object?> get props => [voteSummary, myVote];
}

class VotesLoaded extends CollaborationState {
  final Map<String, VoteSummaryEntity> voteSummary;

  const VotesLoaded(this.voteSummary);

  @override
  List<Object?> get props => [voteSummary];
}

class VenueConfirmed extends CollaborationState {
  final String placeId;

  const VenueConfirmed(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

class SessionSummaryLoaded extends CollaborationState {
  final SessionSummaryEntity summary;

  const SessionSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class VotingStarted extends CollaborationState {
  final SessionSummaryEntity summary;

  const VotingStarted(this.summary);

  @override
  List<Object?> get props => [summary];
}

class CollaborationError extends CollaborationState {
  final String message;

  const CollaborationError(this.message);

  @override
  List<Object?> get props => [message];
}
