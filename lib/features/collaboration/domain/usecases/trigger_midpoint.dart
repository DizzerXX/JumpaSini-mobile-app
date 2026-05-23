import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/collaboration_repository.dart';

class TriggerMidpoint {
  final CollaborationRepository _repository;

  const TriggerMidpoint(this._repository);

  Future<Either<Failure, Unit>> call(String shortCode) =>
      _repository.triggerMidpoint(shortCode);
}
