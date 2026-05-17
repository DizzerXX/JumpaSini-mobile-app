import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/session_model.dart';

abstract class SessionRemoteDatasource {
  Future<SessionModel> createSession({
    required String transportMode,
    required String venueType,
    required bool halalFilter,
  });

  Future<SessionModel> addParticipant({
    required String shortCode,
    String? name,
    required String address,
    required double latitude,
    required double longitude,
  });

  Future<SessionModel> getSession(String shortCode);

  Future<SessionModel> removeParticipant({
    required String shortCode,
    required String participantId,
  });

  /// Returns midpoint coordinates as (lat, lng) after calling the backend.
  Future<({double lat, double lng, bool isFair})> calculateMidpoint(
    String shortCode,
  );
}

class SessionRemoteDatasourceImpl implements SessionRemoteDatasource {
  final ApiClient _client;

  const SessionRemoteDatasourceImpl(this._client);

  @override
  Future<SessionModel> createSession({
    required String transportMode,
    required String venueType,
    required bool halalFilter,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.sessions,
        data: {
          'transport_mode': transportMode,
          'venue_type': venueType,
          'halal_filter': halalFilter,
        },
      );
      return SessionModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<SessionModel> addParticipant({
    required String shortCode,
    String? name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.participants(shortCode),
        data: {
          if (name != null && name.isNotEmpty) 'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return SessionModel.fromJson(data['session'] as Map<String, dynamic>);
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<SessionModel> getSession(String shortCode) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.sessionByCode(shortCode),
      );
      return SessionModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<SessionModel> removeParticipant({
    required String shortCode,
    required String participantId,
  }) async {
    try {
      final response = await _client.dio.delete<Map<String, dynamic>>(
        ApiConstants.participantById(shortCode, participantId),
      );
      return SessionModel.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<({double lat, double lng, bool isFair})> calculateMidpoint(
    String shortCode,
  ) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.midpoint(shortCode),
      );
      final data = response.data!['data'] as Map<String, dynamic>;
      return (
        lat: (data['lat'] as num).toDouble(),
        lng: (data['lng'] as num).toDouble(),
        isFair: data['is_fair'] as bool? ?? true,
      );
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  Never _rethrowMapped(DioException e) {
    final inner = e.error;
    if (inner is NotFoundException) throw inner;
    if (inner is ValidationException) throw inner;
    if (inner is NetworkException) throw inner;
    if (inner is ServerException) throw inner;
    throw ServerException(e.message ?? 'Unexpected error', statusCode: e.response?.statusCode);
  }
}
