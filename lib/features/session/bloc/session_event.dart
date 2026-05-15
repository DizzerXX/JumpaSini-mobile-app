part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class CreateSessionRequested extends SessionEvent {
  final String hostName;
  final String location;

  const CreateSessionRequested({
    required this.hostName,
    required this.location,
  });

  @override
  List<Object?> get props => [hostName, location];
}

class JoinSessionRequested extends SessionEvent {
  final String sessionCode;
  final String participantName;
  final String location;

  const JoinSessionRequested({
    required this.sessionCode,
    required this.participantName,
    required this.location,
  });

  @override
  List<Object?> get props => [sessionCode, participantName, location];
}

class SessionReset extends SessionEvent {
  const SessionReset();
}
