import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/collaboration_repository.dart';

class ConfirmVenue {
  final CollaborationRepository _repository;

  const ConfirmVenue(this._repository);

  Future<Either<Failure, Unit>> call(String shortCode, String placeId) =>
      _repository.confirmVenue(shortCode, placeId);
}
