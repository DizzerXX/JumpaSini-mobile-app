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
  final String sessionCode;
  final String shareLink;

  const SessionCreated({required this.sessionCode, required this.shareLink});

  @override
  List<Object?> get props => [sessionCode, shareLink];
}

class SessionJoined extends SessionState {
  final String sessionCode;

  const SessionJoined({required this.sessionCode});

  @override
  List<Object?> get props => [sessionCode];
}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
