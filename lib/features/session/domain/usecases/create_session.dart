import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

class CreateSessionParams {
  final String transportMode;
  final String venueType;
  final bool halalFilter;

  const CreateSessionParams({
    required this.transportMode,
    required this.venueType,
    required this.halalFilter,
  });
}

class CreateSession {
  final SessionRepository _repository;

  const CreateSession(this._repository);

  Future<SessionEntity> call(CreateSessionParams params) =>
      _repository.createSession(
        transportMode: params.transportMode,
        venueType: params.venueType,
        halalFilter: params.halalFilter,
      );
}
