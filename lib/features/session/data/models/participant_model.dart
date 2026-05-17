import '../../domain/entities/participant_entity.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    required super.id,
    super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.createdAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': createdAt?.toIso8601String(),
      };
}
