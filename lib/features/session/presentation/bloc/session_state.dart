part of 'session_bloc.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionCreated extends SessionState {
  final SessionEntity session;

  const SessionCreated(this.session);

  @override
  List<Object?> get props => [session];
}

class ParticipantAdded extends SessionState {
  final SessionEntity session;

  const ParticipantAdded(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionLoaded extends SessionState {
  final SessionEntity session;

  const SessionLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

class ParticipantRemoved extends SessionState {
  final SessionEntity session;

  const ParticipantRemoved(this.session);

  @override
  List<Object?> get props => [session];
}

class MidpointCalculated extends SessionState {
  final String shortCode;
  final double lat;
  final double lng;
  final bool isFair;

  const MidpointCalculated({
    required this.shortCode,
    required this.lat,
    required this.lng,
    required this.isFair,
  });

  @override
  List<Object?> get props => [shortCode, lat, lng, isFair];
}

class SessionError extends SessionState {
  final String message;
  final Map<String, dynamic>? errors;

  const SessionError(this.message, {this.errors});

  @override
  List<Object?> get props => [message, errors];
}
