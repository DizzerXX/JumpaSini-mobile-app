import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/session_repository.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository _repository;

  SessionBloc(this._repository) : super(const SessionInitial()) {
    on<CreateSessionRequested>(_onCreateSession);
    on<JoinSessionRequested>(_onJoinSession);
    on<SessionReset>((_, emit) => emit(const SessionInitial()));
  }

  Future<void> _onCreateSession(
    CreateSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final result = await _repository.createSession(
        hostName: event.hostName,
        location: event.location,
      );
      emit(SessionCreated(
        sessionCode: result['code'] as String,
        shareLink: result['share_link'] as String,
      ));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onJoinSession(
    JoinSessionRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      await _repository.joinSession(
        sessionCode: event.sessionCode,
        participantName: event.participantName,
        location: event.location,
      );
      emit(SessionJoined(sessionCode: event.sessionCode));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}
