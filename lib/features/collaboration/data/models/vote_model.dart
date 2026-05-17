import '../../domain/entities/vote_entity.dart';

class VoteModel extends VoteEntity {
  const VoteModel({
    required super.sessionId,
    required super.googlePlaceId,
    required super.venueName,
    super.participantName,
    required super.vote,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      sessionId:       json['session_id'] as String? ?? '',
      googlePlaceId:   json['google_place_id'] as String? ?? '',
      venueName:       json['venue_name'] as String? ?? '',
      participantName: json['participant_name'] as String?,
      vote:            json['vote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id':       sessionId,
        'google_place_id':  googlePlaceId,
        'venue_name':       venueName,
        'participant_name': participantName,
        'vote':             vote,
      };
}
