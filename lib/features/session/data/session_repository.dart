import '../../../core/api/api_client.dart';
import '../../../core/api/base_repository.dart';

class SessionRepository extends BaseRepository {
  final ApiClient _client;

  SessionRepository(this._client);

  Future<Map<String, dynamic>> createSession({
    required String hostName,
    required String location,
  }) {
    return safeCall(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/sessions',
        data: {'host_name': hostName, 'location': location},
      );
      return response.data!;
    });
  }

  Future<void> joinSession({
    required String sessionCode,
    required String participantName,
    required String location,
  }) {
    return safeCall(() async {
      await _client.dio.post<void>(
        '/sessions/$sessionCode/join',
        data: {'participant_name': participantName, 'location': location},
      );
    });
  }
}
