import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/session_summary_entity.dart';
import '../entities/vote_summary_entity.dart';

abstract class CollaborationRepository {
  Future<Either<Failure, Map<String, VoteSummaryEntity>>> castVote({
    required String shortCode,
    required String placeId,
    required String venueName,
    String? participantName,
    required String vote,
  });

  Future<Either<Failure, Map<String, VoteSummaryEntity>>> getVotes(
    String shortCode,
  );

  Future<Either<Failure, Unit>> confirmVenue(
    String shortCode,
    String placeId,
  );

  Future<Either<Failure, SessionSummaryEntity>> getSessionSummary(
    String shortCode,
  );

  Future<Either<Failure, SessionSummaryEntity>> startVoting(String shortCode);

  Future<Either<Failure, Unit>> triggerMidpoint(String shortCode);
}
