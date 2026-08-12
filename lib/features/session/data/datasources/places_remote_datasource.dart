import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';

class PlaceSuggestion {
  final String placeId;
  final String primaryText;
  final String secondaryText;
  final String fullText;

  const PlaceSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
    required this.fullText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
        placeId: json['place_id'] as String? ?? '',
        primaryText: json['primary_text'] as String? ?? '',
        secondaryText: json['secondary_text'] as String? ?? '',
        fullText: json['full_text'] as String? ?? '',
      );
}

class ResolvedPlace {
  final String address;
  final double latitude;
  final double longitude;

  const ResolvedPlace({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory ResolvedPlace.fromJson(Map<String, dynamic> json) => ResolvedPlace(
        address: json['address'] as String? ?? '',
        latitude: (json['lat'] as num?)?.toDouble() ?? 0,
        longitude: (json['lng'] as num?)?.toDouble() ?? 0,
      );
}

/// Address lookups via the backend's Places proxy.
///
/// Deliberately does NOT use flutter_google_places_sdk: the backend holds the only
/// Places-capable key and caches every lookup, so autocomplete isn't billed once per
/// keystroke per device — and no Google key needs to ship inside the APK.
abstract class PlacesRemoteDatasource {
  Future<List<PlaceSuggestion>> autocomplete(String input, {String? sessionToken});

  Future<ResolvedPlace> details(String placeId, {String? sessionToken});

  Future<String> reverseGeocode(double lat, double lng);
}

class PlacesRemoteDatasourceImpl implements PlacesRemoteDatasource {
  final ApiClient _client;

  const PlacesRemoteDatasourceImpl(this._client);

  @override
  Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    String? sessionToken,
  }) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.placesAutocomplete,
        queryParameters: {
          'input': input,
          if (sessionToken != null) 'session_token': sessionToken,
        },
      );

      final data = response.data!['data'] as List<dynamic>? ?? [];

      return data
          .map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<ResolvedPlace> details(String placeId, {String? sessionToken}) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.placeDetails(placeId),
        queryParameters: {
          if (sessionToken != null) 'session_token': sessionToken,
        },
      );

      return ResolvedPlace.fromJson(
        response.data!['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _rethrowMapped(e);
    }
  }

  @override
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.placesReverseGeocode,
        queryParameters: {'lat': lat, 'lng': lng},
      );

      final data = response.data!['data'] as Map<String, dynamic>;

      return data['address'] as String? ?? '';
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
