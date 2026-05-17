import 'package:equatable/equatable.dart';

import 'travel_time.dart';

class VenueEntity extends Equatable {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String type;
  final double? rating;
  final bool? isHalal;
  final bool isHalalVerified;
  final int distanceMeters;
  final String? photoUrl;
  final String googleMapsUrl;
  final String source;
  final Map<String, TravelTime> travelTimes;
  final bool isBestPick;
  final double score;

  const VenueEntity({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.type,
    this.rating,
    this.isHalal,
    required this.isHalalVerified,
    required this.distanceMeters,
    this.photoUrl,
    required this.googleMapsUrl,
    required this.source,
    this.travelTimes = const {},
    this.isBestPick = false,
    this.score = 0.0,
  });

  @override
  List<Object?> get props => [
        placeId,
        name,
        address,
        lat,
        lng,
        type,
        rating,
        isHalal,
        isHalalVerified,
        distanceMeters,
        photoUrl,
        googleMapsUrl,
        source,
        travelTimes,
        isBestPick,
        score,
      ];
}
