import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/recommendation_model.dart';
import '../models/venue_model.dart';

abstract class VenueRemoteDatasource {
  Future<List<VenueModel>> getVenues(String shortCode);

  Future<RecommendationModel> getRecommendation(String shortCode);

  Future<void> reportHalal(String placeId, bool isHalal, String? sessionId);
}

class VenueRemoteDatasourceImpl implements VenueRemoteDatasource {
  final ApiClient _client;

  const VenueRemoteDatasourceImpl(this._client);

  @override
  Future<List<VenueModel>> getVenues(String shortCode) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.venues(shortCode),
      );
      final list = response.data!['data'] as List<dynamic>;
      return list
          .map((e) => VenueModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<RecommendationModel> getRecommendation(String shortCode) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.recommendation(shortCode),
      );
      return RecommendationModel.fromJson(response.data!);
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<void> reportHalal(
    String placeId,
    bool isHalal,
    String? sessionId,
  ) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.halalReport(placeId),
        data: {
          'reported_as_halal': isHalal,
          if (sessionId != null) 'session_id': sessionId,
        },
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
