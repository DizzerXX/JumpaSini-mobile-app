import 'package:flutter/material.dart';

import '../../domain/entities/vote_summary_entity.dart';

class VoteTally extends StatelessWidget {
  final Map<String, VoteSummaryEntity> voteSummary;

  const VoteTally({super.key, required this.voteSummary});

  @override
  Widget build(BuildContext context) {
    if (voteSummary.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No votes yet. Be the first to vote!',
          style: TextStyle(color: Colors.black45, fontSize: 13),
        ),
      );
    }

    final sorted = voteSummary.values.toList()
      ..sort((a, b) => b.upVotes.compareTo(a.upVotes));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted.map((summary) => _TallyRow(summary: summary)).toList(),
    );
  }
}

class _TallyRow extends StatelessWidget {
  final VoteSummaryEntity summary;

  const _TallyRow({required this.summary});

  Color get _barColor {
    if (summary.total == 0) return Colors.grey.shade300;
    return summary.upVotes >= summary.downVotes ? Colors.green : Colors.red;
  }

  double get _ratio {
    if (summary.total == 0) return 0;
    return summary.upVotes / summary.total;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  summary.placeId,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '👍 ${summary.upVotes}  👎 ${summary.downVotes}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
        ],
      ),
    );
  }
}
