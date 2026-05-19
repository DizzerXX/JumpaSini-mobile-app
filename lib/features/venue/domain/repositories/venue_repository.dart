import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recommendation_entity.dart';
import '../entities/venue_entity.dart';
import '../entities/weather_assessment.dart';

abstract class VenueRepository {
  Future<Either<Failure, List<VenueEntity>>> getVenues(String shortCode);

  Future<Either<Failure, WeatherAssessment>> getWeather(String shortCode);

  Future<Either<Failure, RecommendationEntity>> getRecommendation(
    String shortCode,
  );

  Future<Either<Failure, Unit>> reportHalal(
    String placeId,
    bool isHalal,
    String? sessionId,
  );
}
