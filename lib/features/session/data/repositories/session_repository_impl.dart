import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_datasource.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDatasource _datasource;

  const SessionRepositoryImpl(this._datasource);

  @override
  Future<SessionEntity> createSession({
    required String transportMode,
    required String venueType,
    required bool halalFilter,
  }) async {
    try {
      return await _datasource.createSession(
        transportMode: transportMode,
        venueType: venueType,
        halalFilter: halalFilter,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<SessionEntity> addParticipant({
    required String shortCode,
    String? name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _datasource.addParticipant(
        shortCode: shortCode,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message, errors: e.errors);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<SessionEntity> getSession(String shortCode) async {
    try {
      return await _datasource.getSession(shortCode);
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<SessionEntity> removeParticipant({
    required String shortCode,
    required String participantId,
  }) async {
    try {
      return await _datasource.removeParticipant(
        shortCode: shortCode,
        participantId: participantId,
      );
    } on NotFoundException catch (e) {
      throw NotFoundFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<({double lat, double lng, bool isFair})> calculateMidpoint(
    String shortCode,
  ) async {
    try {
      return await _datasource.calculateMidpoint(shortCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    }
  }
}
