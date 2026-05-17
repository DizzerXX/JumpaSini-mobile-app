import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recommendation_entity.dart';
import '../repositories/venue_repository.dart';

class GetRecommendation {
  final VenueRepository _repository;

  const GetRecommendation(this._repository);

  Future<Either<Failure, RecommendationEntity>> call(String shortCode) {
    return _repository.getRecommendation(shortCode);
  }
}
