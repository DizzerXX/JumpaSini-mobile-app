import '../../domain/entities/travel_time.dart';
import '../../domain/entities/venue_entity.dart';

class VenueModel extends VenueEntity {
  const VenueModel({
    required super.placeId,
    required super.name,
    required super.address,
    required super.lat,
    required super.lng,
    required super.type,
    super.rating,
    super.isHalal,
    required super.isHalalVerified,
    required super.distanceMeters,
    super.photoUrl,
    required super.googleMapsUrl,
    required super.source,
    super.travelTimes = const {},
    super.isBestPick = false,
    super.score = 0.0,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    final rawTravelTimes =
        json['travel_times'] as Map<String, dynamic>? ?? {};
    final travelTimes = rawTravelTimes.map(
      (key, value) {
        final entry = value as Map<String, dynamic>;
        return MapEntry(
          key,
          TravelTime(
            seconds: (entry['seconds'] as num).toInt(),
            text: entry['text'] as String? ?? '',
          ),
        );
      },
    );

    return VenueModel(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: json['type'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      isHalal: json['is_halal'] as bool?,
      isHalalVerified: json['is_halal_verified'] as bool? ?? false,
      distanceMeters: (json['distance_meters'] as num).toInt(),
      photoUrl: json['photo_url'] as String?,
      googleMapsUrl: json['google_maps_url'] as String,
      source: json['source'] as String,
      travelTimes: travelTimes,
      isBestPick: json['is_best_pick'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'type': type,
        'rating': rating,
        'is_halal': isHalal,
        'is_halal_verified': isHalalVerified,
        'distance_meters': distanceMeters,
        'photo_url': photoUrl,
        'google_maps_url': googleMapsUrl,
        'source': source,
        'travel_times': travelTimes.map(
          (k, v) => MapEntry(k, {'seconds': v.seconds, 'text': v.text}),
        ),
        'is_best_pick': isBestPick,
        'score': score,
      };
}
