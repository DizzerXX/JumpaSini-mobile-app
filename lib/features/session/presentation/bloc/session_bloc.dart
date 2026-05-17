import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/add_participant.dart';
import '../../domain/usecases/calculate_midpoint.dart';
import '../../domain/usecases/create_session.dart';
import '../../domain/usecases/get_session.dart';
import '../../domain/usecases/remove_participant.dart';
import '../../../../core/errors/failures.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final CreateSession _createSession;
  final AddParticipant _addParticipant;
  final GetSession _getSession;
  final RemoveParticipant _removeParticipant;
  final CalculateMidpoint _calculateMidpoint;

  SessionBloc({
    required CreateSession createSession,
    required AddParticipant addParticipant,
    required GetSession getSession,
    required RemoveParticipant removeParticipant,
    required CalculateMidpoint calculateMidpoint,
  })  : _createSession = createSession,
        _addParticipant = addParticipant,
        _getSession = getSession,
        _removeParticipant = removeParticipant,
        _calculateMidpoint = calculateMidpoint,
        super(const SessionInitial()) {
    on<CreateSessionEvent>(_onCreateSession);
    on<AddParticipantEvent>(_onAddParticipant);
    on<GetSessionEvent>(_onGetSession);
    on<RemoveParticipantEvent>(_onRemoveParticipant);
    on<CalculateMidpointEvent>(_onCalculateMidpoint);
  }

  Future<void> _onCreateSession(
    CreateSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final session = await _createSession(
        CreateSessionParams(
          transportMode: event.transportMode,
          venueType: event.venueType,
          halalFilter: event.halalFilter,
        ),
      );
      emit(SessionCreated(session));
    } on Failure catch (e) {
      emit(SessionError(_failureMessage(e)));
    }
  }

  Future<void> _onAddParticipant(
    AddParticipantEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final session = await _addParticipant(
        AddParticipantParams(
          shortCode: event.shortCode,
          name: event.name,
          address: event.address,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      );
      emit(ParticipantAdded(session));
    } on ValidationFailure catch (e) {
      emit(SessionError(e.message, errors: e.errors));
    } on Failure catch (e) {
      emit(SessionError(_failureMessage(e)));
    }
  }

  Future<void> _onGetSession(
    GetSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final session = await _getSession(event.shortCode);
      emit(SessionLoaded(session));
    } on Failure catch (e) {
      emit(SessionError(_failureMessage(e)));
    }
  }

  Future<void> _onRemoveParticipant(
    RemoveParticipantEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final session = await _removeParticipant(
        RemoveParticipantParams(
          shortCode: event.shortCode,
          participantId: event.participantId,
        ),
      );
      emit(ParticipantRemoved(session));
    } on Failure catch (e) {
      emit(SessionError(_failureMessage(e)));
    }
  }

  Future<void> _onCalculateMidpoint(
    CalculateMidpointEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final result = await _calculateMidpoint(event.shortCode);
      emit(MidpointCalculated(
        shortCode: event.shortCode,
        lat: result.lat,
        lng: result.lng,
        isFair: result.isFair,
      ));
    } on Failure catch (e) {
      emit(SessionError(_failureMessage(e)));
    }
  }

  String _failureMessage(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection. Please try again.';
    if (failure is NotFoundFailure) return 'Session not found. Check the code and try again.';
    if (failure is ValidationFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Something went wrong. Please try again.';
  }
}
