import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/session_summary_entity.dart';
import '../repositories/collaboration_repository.dart';

class StartVoting {
  final CollaborationRepository _repository;

  const StartVoting(this._repository);

  Future<Either<Failure, SessionSummaryEntity>> call(String shortCode) =>
      _repository.startVoting(shortCode);
}
