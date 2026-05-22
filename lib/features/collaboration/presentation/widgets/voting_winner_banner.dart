import 'package:flutter/material.dart';

import '../../domain/entities/vote_summary_entity.dart';

class VotingWinnerBanner extends StatelessWidget {
  final String? winningPlaceId;
  final Map<String, VoteSummaryEntity> voteSummary;
  final Map<String, String> venueNames;

  const VotingWinnerBanner({
    super.key,
    required this.winningPlaceId,
    required this.voteSummary,
    required this.venueNames,
  });

  @override
  Widget build(BuildContext context) {
    if (winningPlaceId == null || voteSummary.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: const Row(
          children: [
            Text('🗳️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Text(
              'No votes yet — cast your vote!',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final winner = voteSummary[winningPlaceId!];
    if (winner == null) return const SizedBox.shrink();

    final name =
        venueNames[winningPlaceId] ?? _shortId(winningPlaceId!);

    final sorted = voteSummary.values.toList()
      ..sort((a, b) => b.upVotes.compareTo(a.upVotes));
    final votesAhead = sorted.length >= 2
        ? winner.upVotes - sorted[1].upVotes
        : winner.upVotes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT LEADER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (votesAhead > 0)
                  Text(
                    '$votesAhead vote${votesAhead == 1 ? '' : 's'} ahead',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${winner.upVotes}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                '👍',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortId(String id) =>
      id.length <= 14 ? id : '${id.substring(0, 14)}…';
}
