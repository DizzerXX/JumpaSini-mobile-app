import '../../domain/entities/vote_summary_entity.dart';

class VoteSummaryModel extends VoteSummaryEntity {
  const VoteSummaryModel({
    required super.placeId,
    required super.upVotes,
    required super.downVotes,
    required super.total,
    super.myVote,
  });

  factory VoteSummaryModel.fromJson(String placeId, Map<String, dynamic> json) {
    return VoteSummaryModel(
      placeId:   placeId,
      upVotes:   (json['up'] as num?)?.toInt() ?? 0,
      downVotes: (json['down'] as num?)?.toInt() ?? 0,
      total:     (json['total'] as num?)?.toInt() ?? 0,
      myVote:    json['my_vote'] as String?,
    );
  }

  static Map<String, VoteSummaryModel> mapFromJson(
    Map<String, dynamic> rawMap,
  ) {
    return rawMap.map(
      (placeId, value) => MapEntry(
        placeId,
        VoteSummaryModel.fromJson(placeId, value as Map<String, dynamic>),
      ),
    );
  }
}
