import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_datasource.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDatasource _datasource;

  const SessionRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SessionEntity>> createSession({
    required String transportMode,
    required String venueType,
    required bool halalFilter,
  }) {
    return _guard(() => _datasource.createSession(
          transportMode: transportMode,
          venueType: venueType,
          halalFilter: halalFilter,
        ));
  }

  @override
  Future<Either<Failure, SessionEntity>> addParticipant({
    required String shortCode,
    String? name,
    required String address,
    required double latitude,
    required double longitude,
  }) {
    return _guard(() => _datasource.addParticipant(
          shortCode: shortCode,
          name: name,
          address: address,
          latitude: latitude,
          longitude: longitude,
        ));
  }

  @override
  Future<Either<Failure, SessionEntity>> getSession(String shortCode) {
    return _guard(() => _datasource.getSession(shortCode));
  }

  @override
  Future<Either<Failure, SessionEntity>> removeParticipant({
    required String shortCode,
    required String participantId,
  }) {
    return _guard(() => _datasource.removeParticipant(
          shortCode: shortCode,
          participantId: participantId,
        ));
  }

  @override
  Future<Either<Failure, ({double lat, double lng, bool isFair})>> calculateMidpoint(
    String shortCode,
  ) {
    return _guard(() => _datasource.calculateMidpoint(shortCode));
  }

  /// Single translation point from data-layer exceptions to domain failures —
  /// previously each method repeated the same four catch clauses.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
