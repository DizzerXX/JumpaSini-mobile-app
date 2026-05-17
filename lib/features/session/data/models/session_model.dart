import '../../domain/entities/session_entity.dart';
import 'participant_model.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.shortCode,
    required super.transportMode,
    required super.venueType,
    required super.halalFilter,
    required super.status,
    required super.expiresAt,
    super.participants,
    super.createdAt,
    super.shareableUrl,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final participantsList = json['participants'] as List<dynamic>? ?? [];
    return SessionModel(
      id: json['id'] as String? ?? '',
      shortCode: json['short_code'] as String? ?? '',
      transportMode: json['transport_mode'] as String? ?? '',
      venueType: json['venue_type'] as String? ?? '',
      halalFilter: json['halal_filter'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : DateTime.now(),
      participants: participantsList
          .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      shareableUrl: json['shareable_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'short_code': shortCode,
        'transport_mode': transportMode,
        'venue_type': venueType,
        'halal_filter': halalFilter,
        'status': status,
        'expires_at': expiresAt.toIso8601String(),
        'participants': participants
            .map((p) => (p as ParticipantModel).toJson())
            .toList(),
        'created_at': createdAt?.toIso8601String(),
      };
}
