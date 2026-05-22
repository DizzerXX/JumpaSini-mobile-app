import 'package:equatable/equatable.dart';

class VotingStateEntity extends Equatable {
  final bool active;
  final DateTime? endsAt;
  final int secondsRemaining;
  final String? winningVenue;
  final String? votingConfirmedVenue;

  const VotingStateEntity({
    required this.active,
    this.endsAt,
    required this.secondsRemaining,
    this.winningVenue,
    this.votingConfirmedVenue,
  });

  @override
  List<Object?> get props => [
        active,
        endsAt,
        secondsRemaining,
        winningVenue,
        votingConfirmedVenue,
      ];
}
