import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

class RemoveParticipantParams {
  final String shortCode;
  final String participantId;

  const RemoveParticipantParams({
    required this.shortCode,
    required this.participantId,
  });
}

class RemoveParticipant {
  final SessionRepository _repository;

  const RemoveParticipant(this._repository);

  Future<SessionEntity> call(RemoveParticipantParams params) =>
      _repository.removeParticipant(
        shortCode: params.shortCode,
        participantId: params.participantId,
      );
}
