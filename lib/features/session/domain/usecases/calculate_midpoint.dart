import '../repositories/session_repository.dart';

class CalculateMidpoint {
  final SessionRepository _repository;

  const CalculateMidpoint(this._repository);

  Future<({double lat, double lng, bool isFair})> call(String shortCode) =>
      _repository.calculateMidpoint(shortCode);
}
