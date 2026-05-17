import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/venue_entity.dart';
import '../repositories/venue_repository.dart';

class GetVenues {
  final VenueRepository _repository;

  const GetVenues(this._repository);

  Future<Either<Failure, List<VenueEntity>>> call(String shortCode) =>
      _repository.getVenues(shortCode);
}
