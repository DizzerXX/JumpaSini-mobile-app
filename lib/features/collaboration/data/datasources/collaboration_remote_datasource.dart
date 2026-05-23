import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/vote_summary_entity.dart';
import '../models/session_summary_model.dart';
import '../models/vote_summary_model.dart';
import '../../domain/entities/session_summary_entity.dart';

abstract class CollaborationRemoteDatasource {
  Future<Map<String, VoteSummaryEntity>> castVote({
    required String shortCode,
    required String placeId,
    required String venueName,
    String? participantName,
    required String vote,
  });

  Future<Map<String, VoteSummaryEntity>> getVotes(String shortCode);

  Future<void> confirmVenue(String shortCode, String placeId);

  Future<SessionSummaryEntity> getSessionSummary(String shortCode);

  Future<SessionSummaryEntity> startVoting(String shortCode);

  Future<void> triggerMidpoint(String shortCode);
}

class CollaborationRemoteDatasourceImpl
    implements CollaborationRemoteDatasource {
  final ApiClient _client;

  const CollaborationRemoteDatasourceImpl(this._client);

  @override
  Future<Map<String, VoteSummaryEntity>> castVote({
    required String shortCode,
    required String placeId,
    required String venueName,
    String? participantName,
    required String vote,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.votes(shortCode),
        data: {
          'google_place_id':  placeId,
          'venue_name':       venueName,
          if (participantName != null) 'participant_name': participantName,
          'vote':             vote,
        },
      );
      final rawSummary =
          response.data!['data']['vote_summary'] as Map<String, dynamic>;
      return VoteSummaryModel.mapFromJson(rawSummary);
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<Map<String, VoteSummaryEntity>> getVotes(String shortCode) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.votes(shortCode),
      );
      final rawSummary =
          response.data!['data']['vote_summary'] as Map<String, dynamic>;
      return VoteSummaryModel.mapFromJson(rawSummary);
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<void> confirmVenue(String shortCode, String placeId) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.confirm(shortCode),
        data: {'google_place_id': placeId},
      );
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<SessionSummaryEntity> getSessionSummary(String shortCode) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.summary(shortCode),
      );
      return SessionSummaryModel.fromJson(response.data!);
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<SessionSummaryEntity> startVoting(String shortCode) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.votingStart(shortCode),
      );
      return SessionSummaryModel.fromJson(response.data!);
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<void> triggerMidpoint(String shortCode) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.midpoint(shortCode),
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
    throw ServerException(
      e.message ?? 'Unexpected error',
      statusCode: e.response?.statusCode,
    );
  }
}
