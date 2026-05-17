import 'package:equatable/equatable.dart';

class VoteSummaryEntity extends Equatable {
  final String placeId;
  final int upVotes;
  final int downVotes;
  final int total;
  final String? myVote;

  const VoteSummaryEntity({
    required this.placeId,
    required this.upVotes,
    required this.downVotes,
    required this.total,
    this.myVote,
  });

  @override
  List<Object?> get props => [placeId, upVotes, downVotes, total, myVote];
}
