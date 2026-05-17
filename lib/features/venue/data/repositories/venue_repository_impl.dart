import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/repositories/venue_repository.dart';
import '../datasources/venue_remote_datasource.dart';

class VenueRepositoryImpl implements VenueRepository {
  final VenueRemoteDatasource _datasource;

  const VenueRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<VenueEntity>>> getVenues(String shortCode) async {
    try {
      final venues = await _datasource.getVenues(shortCode);
      return Right(venues);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Unit>> reportHalal(
    String placeId,
    bool isHalal,
    String? sessionId,
  ) async {
    try {
      await _datasource.reportHalal(placeId, isHalal, sessionId);
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
