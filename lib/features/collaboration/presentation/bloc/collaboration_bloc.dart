import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/cast_vote.dart';
import '../../domain/usecases/confirm_venue.dart';
import '../../domain/usecases/get_session_summary.dart';
import '../../domain/usecases/get_votes.dart';
import '../../domain/usecases/start_voting.dart';
import '../../domain/usecases/trigger_midpoint.dart';
import 'collaboration_event.dart';
import 'collaboration_state.dart';

class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  final CastVote _castVote;
  final GetVotes _getVotes;
  final ConfirmVenue _confirmVenue;
  final GetSessionSummary _getSessionSummary;
  final StartVoting _startVoting;
  final TriggerMidpoint _triggerMidpoint;

  CollaborationBloc({
    required CastVote castVote,
    required GetVotes getVotes,
    required ConfirmVenue confirmVenue,
    required GetSessionSummary getSessionSummary,
    required StartVoting startVoting,
    required TriggerMidpoint triggerMidpoint,
  })  : _castVote = castVote,
        _getVotes = getVotes,
        _confirmVenue = confirmVenue,
        _getSessionSummary = getSessionSummary,
        _startVoting = startVoting,
        _triggerMidpoint = triggerMidpoint,
        super(const CollaborationInitial()) {
    on<CastVoteEvent>(_onCastVote);
    on<GetVotesEvent>(_onGetVotes);
    on<ConfirmVenueEvent>(_onConfirmVenue);
    on<GetSessionSummaryEvent>(_onGetSessionSummary);
    on<StartVotingEvent>(_onStartVoting);
    on<TriggerMidpointEvent>(_onTriggerMidpoint);
  }

  Future<void> _onCastVote(
    CastVoteEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(const CollaborationLoading());
    final result = await _castVote(
      shortCode:       event.shortCode,
      placeId:         event.placeId,
      venueName:       event.venueName,
      participantName: event.participantName,
      vote:            event.vote,
    );
    result.fold(
      (failure) => emit(CollaborationError(failure.message)),
      (voteSummary) => emit(VoteCast(voteSummary: voteSummary, myVote: event.vote)),
    );
  }

  Future<void> _onGetVotes(
    GetVotesEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(const CollaborationLoading());
    final result = await _getVotes(event.shortCode);
    result.fold(
      (failure) => emit(CollaborationError(failure.message)),
      (voteSummary) => emit(VotesLoaded(voteSummary)),
    );
  }

  Future<void> _onConfirmVenue(
    ConfirmVenueEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(const CollaborationLoading());
    final result = await _confirmVenue(event.shortCode, event.placeId);
    result.fold(
      (failure) => emit(CollaborationError(failure.message)),
      (_) {
        emit(VenueConfirmed(event.placeId));
        add(GetSessionSummaryEvent(event.shortCode));
      },
    );
  }

  Future<void> _onGetSessionSummary(
    GetSessionSummaryEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    if (!event.silent) emit(const CollaborationLoading());
    final result = await _getSessionSummary(event.shortCode);
    result.fold(
      (failure) => emit(CollaborationError(failure.message)),
      (summary) => emit(SessionSummaryLoaded(summary)),
    );
  }

  Future<void> _onStartVoting(
    StartVotingEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(const CollaborationLoading());
    final result = await _startVoting(event.shortCode);
    result.fold(
      (failure) => emit(CollaborationError(failure.message)),
      (summary) => emit(VotingStarted(summary)),
    );
  }

  Future<void> _onTriggerMidpoint(
    TriggerMidpointEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(const CollaborationLoading());
    final result = await _triggerMidpoint(event.shortCode);
    result.fold(
      (failure) => emit(CollaborationError(failure.message)),
      (_) => add(GetSessionSummaryEvent(event.shortCode)),
    );
  }
}
