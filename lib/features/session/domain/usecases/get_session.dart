import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

class GetSession {
  final SessionRepository _repository;

  const GetSession(this._repository);

  Future<Either<Failure, SessionEntity>> call(String shortCode) =>
      _repository.getSession(shortCode);
}
