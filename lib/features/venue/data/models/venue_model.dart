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
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
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
      distanceMeters: json['distance_meters'] as int,
      photoUrl: json['photo_url'] as String?,
      googleMapsUrl: json['google_maps_url'] as String,
      source: json['source'] as String,
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
      };
}
