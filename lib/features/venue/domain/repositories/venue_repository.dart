import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/venue_entity.dart';

abstract class VenueRepository {
  Future<Either<Failure, List<VenueEntity>>> getVenues(String shortCode);

  Future<Either<Failure, Unit>> reportHalal(
    String placeId,
    bool isHalal,
    String? sessionId,
  );
}
