import 'package:equatable/equatable.dart';

import 'participant_entity.dart';

class SessionEntity extends Equatable {
  final String id;
  final String shortCode;
  final String transportMode;
  final String venueType;
  final bool halalFilter;
  final String status;
  final DateTime expiresAt;
  final List<ParticipantEntity> participants;
  final DateTime? createdAt;
  final String? shareableUrl;

  const SessionEntity({
    required this.id,
    required this.shortCode,
    required this.transportMode,
    required this.venueType,
    required this.halalFilter,
    required this.status,
    required this.expiresAt,
    this.participants = const [],
    this.createdAt,
    this.shareableUrl,
  });

  int get participantCount => participants.length;

  bool get isFull => participants.length >= 6;

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        shortCode,
        transportMode,
        venueType,
        halalFilter,
        status,
        expiresAt,
        participants,
        createdAt,
        shareableUrl,
      ];
}
