import 'package:equatable/equatable.dart';

class ParticipantEntity extends Equatable {
  final String id;
  final String? name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  const ParticipantEntity({
    required this.id,
    this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, createdAt];
}
