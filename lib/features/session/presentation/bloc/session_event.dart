part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class CreateSessionEvent extends SessionEvent {
  final String transportMode;
  final String venueType;
  final bool halalFilter;

  const CreateSessionEvent({
    required this.transportMode,
    required this.venueType,
    required this.halalFilter,
  });

  @override
  List<Object?> get props => [transportMode, venueType, halalFilter];
}

class AddParticipantEvent extends SessionEvent {
  final String shortCode;
  final String? name;
  final String address;
  final double latitude;
  final double longitude;

  const AddParticipantEvent({
    required this.shortCode,
    this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [shortCode, name, address, latitude, longitude];
}

class GetSessionEvent extends SessionEvent {
  final String shortCode;

  const GetSessionEvent(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}

class RemoveParticipantEvent extends SessionEvent {
  final String shortCode;
  final String participantId;

  const RemoveParticipantEvent({
    required this.shortCode,
    required this.participantId,
  });

  @override
  List<Object?> get props => [shortCode, participantId];
}

class CalculateMidpointEvent extends SessionEvent {
  final String shortCode;

  const CalculateMidpointEvent(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}
