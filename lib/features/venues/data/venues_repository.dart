import '../../../core/api/api_client.dart';
import '../../../core/api/base_repository.dart';

class VenuesRepository extends BaseRepository {
  final ApiClient _client;

  VenuesRepository(this._client);

  Future<Map<String, dynamic>> fetchVenues(String sessionCode) {
    return safeCall(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/sessions/$sessionCode/venues',
      );
      return response.data!;
    });
  }
}
