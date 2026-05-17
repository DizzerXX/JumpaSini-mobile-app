import '../../domain/entities/participant_travel_summary.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/entities/travel_time.dart';
import 'venue_model.dart';

class RecommendationModel extends RecommendationEntity {
  const RecommendationModel({
    required super.sessionShortCode,
    required super.midpointLat,
    required super.midpointLng,
    required super.bestVenue,
    required super.participantSummary,
    required super.fairnessScore,
    required super.transportMode,
    required super.venueType,
    required super.calculatedAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final midpoint = data['midpoint'] as Map<String, dynamic>;
    final bestVenueJson = data['best_venue'] as Map<String, dynamic>;

    final rawSummary =
        data['participant_summary'] as List<dynamic>? ?? [];
    final participantSummary = rawSummary.map((e) {
      final entry = e as Map<String, dynamic>;
      final rawTt = entry['travel_time_to_best'] as Map<String, dynamic>?;
      return ParticipantTravelSummary(
        participantId: entry['participant_id'] as String? ?? '',
        name: entry['name'] as String? ?? '',
        travelTimeToBest: rawTt != null
            ? TravelTime(
                seconds: (rawTt['seconds'] as num).toInt(),
                text: rawTt['text'] as String? ?? '',
              )
            : null,
        startingAddress: entry['starting_address'] as String? ?? '',
      );
    }).toList();

    return RecommendationModel(
      sessionShortCode: data['session_short_code'] as String? ?? '',
      midpointLat: (midpoint['lat'] as num).toDouble(),
      midpointLng: (midpoint['lng'] as num).toDouble(),
      bestVenue: VenueModel.fromJson(bestVenueJson),
      participantSummary: participantSummary,
      fairnessScore: (data['fairness_score'] as num?)?.toDouble() ?? 0.0,
      transportMode: data['transport_mode'] as String? ?? '',
      venueType: data['venue_type'] as String? ?? '',
      calculatedAt: data['calculated_at'] != null
          ? DateTime.parse(data['calculated_at'] as String)
          : DateTime.now(),
    );
  }
}
