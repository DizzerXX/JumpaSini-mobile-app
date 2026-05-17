import '../entities/session_entity.dart';

abstract class SessionRepository {
  Future<SessionEntity> createSession({
    required String transportMode,
    required String venueType,
    required bool halalFilter,
  });

  Future<SessionEntity> addParticipant({
    required String shortCode,
    String? name,
    required String address,
    required double latitude,
    required double longitude,
  });

  Future<SessionEntity> getSession(String shortCode);

  Future<SessionEntity> removeParticipant({
    required String shortCode,
    required String participantId,
  });

  Future<({double lat, double lng, bool isFair})> calculateMidpoint(
    String shortCode,
  );
}
