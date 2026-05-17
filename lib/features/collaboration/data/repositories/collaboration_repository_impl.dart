import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session_summary_entity.dart';
import '../../domain/entities/vote_summary_entity.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../datasources/collaboration_remote_datasource.dart';

class CollaborationRepositoryImpl implements CollaborationRepository {
  final CollaborationRemoteDatasource _datasource;

  const CollaborationRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Map<String, VoteSummaryEntity>>> castVote({
    required String shortCode,
    required String placeId,
    required String venueName,
    String? participantName,
    required String vote,
  }) async {
    try {
      final result = await _datasource.castVote(
        shortCode:       shortCode,
        placeId:         placeId,
        venueName:       venueName,
        participantName: participantName,
        vote:            vote,
      );
      return Right(result);
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

  @override
  Future<Either<Failure, Map<String, VoteSummaryEntity>>> getVotes(
    String shortCode,
  ) async {
    try {
      final result = await _datasource.getVotes(shortCode);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmVenue(
    String shortCode,
    String placeId,
  ) async {
    try {
      await _datasource.confirmVenue(shortCode, placeId);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, SessionSummaryEntity>> getSessionSummary(
    String shortCode,
  ) async {
    try {
      final result = await _datasource.getSessionSummary(shortCode);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
