import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/session_entity.dart';

/// Returns Either<Failure, T> like the venue and collaboration repositories.
/// Failures are values here, never thrown — one convention across every feature.
abstract class SessionRepository {
  Future<Either<Failure, SessionEntity>> createSession({
    required String transportMode,
    required String venueType,
    required bool halalFilter,
  });

  Future<Either<Failure, SessionEntity>> addParticipant({
    required String shortCode,
    String? name,
    required String address,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, SessionEntity>> getSession(String shortCode);

  Future<Either<Failure, SessionEntity>> removeParticipant({
    required String shortCode,
    required String participantId,
  });

  Future<Either<Failure, ({double lat, double lng, bool isFair})>> calculateMidpoint(
    String shortCode,
  );
}
