import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/session_summary_entity.dart';
import '../repositories/collaboration_repository.dart';

class GetSessionSummary {
  final CollaborationRepository _repository;

  const GetSessionSummary(this._repository);

  Future<Either<Failure, SessionSummaryEntity>> call(String shortCode) =>
      _repository.getSessionSummary(shortCode);
}
