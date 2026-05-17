import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/vote_summary_entity.dart';
import '../repositories/collaboration_repository.dart';

class CastVote {
  final CollaborationRepository _repository;

  const CastVote(this._repository);

  Future<Either<Failure, Map<String, VoteSummaryEntity>>> call({
    required String shortCode,
    required String placeId,
    required String venueName,
    String? participantName,
    required String vote,
  }) =>
      _repository.castVote(
        shortCode:       shortCode,
        placeId:         placeId,
        venueName:       venueName,
        participantName: participantName,
        vote:            vote,
      );
}
