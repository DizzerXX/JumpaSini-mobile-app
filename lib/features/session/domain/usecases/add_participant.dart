import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

class AddParticipantParams {
  final String shortCode;
  final String? name;
  final String address;
  final double latitude;
  final double longitude;

  const AddParticipantParams({
    required this.shortCode,
    this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class AddParticipant {
  final SessionRepository _repository;

  const AddParticipant(this._repository);

  Future<Either<Failure, SessionEntity>> call(AddParticipantParams params) =>
      _repository.addParticipant(
        shortCode: params.shortCode,
        name: params.name,
        address: params.address,
        latitude: params.latitude,
        longitude: params.longitude,
      );
}
