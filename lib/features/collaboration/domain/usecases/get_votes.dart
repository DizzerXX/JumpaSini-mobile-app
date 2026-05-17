import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/vote_summary_entity.dart';
import '../repositories/collaboration_repository.dart';

class GetVotes {
  final CollaborationRepository _repository;

  const GetVotes(this._repository);

  Future<Either<Failure, Map<String, VoteSummaryEntity>>> call(
    String shortCode,
  ) =>
      _repository.getVotes(shortCode);
}
