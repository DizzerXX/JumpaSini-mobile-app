import 'package:flutter/material.dart';

import '../../domain/entities/travel_time.dart';

class TravelTimeRow extends StatelessWidget {
  final Map<String, TravelTime> travelTimes;
  final Map<String, String> participantNames;

  const TravelTimeRow({
    super.key,
    required this.travelTimes,
    required this.participantNames,
  });

  Color _chipColor(int seconds) {
    if (seconds < 1200) return Colors.green.shade100;
    if (seconds <= 2400) return Colors.amber.shade100;
    return Colors.red.shade100;
  }

  Color _chipBorderColor(int seconds) {
    if (seconds < 1200) return Colors.green.shade400;
    if (seconds <= 2400) return Colors.amber.shade400;
    return Colors.red.shade400;
  }

  Color _chipTextColor(int seconds) {
    if (seconds < 1200) return Colors.green.shade800;
    if (seconds <= 2400) return Colors.amber.shade800;
    return Colors.red.shade800;
  }

  @override
  Widget build(BuildContext context) {
    if (travelTimes.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: travelTimes.entries.map((entry) {
          final participantId = entry.key;
          final tt = entry.value;
          final name = participantNames[participantId] ?? participantId;
          final shortName =
              name.length > 10 ? '${name.substring(0, 10)}…' : name;

          return Container(
            margin: const EdgeInsets.only(right: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _chipColor(tt.seconds),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chipBorderColor(tt.seconds)),
            ),
            child: Text(
              '👤 $shortName: ${tt.text}',
              style: TextStyle(
                fontSize: 11,
                color: _chipTextColor(tt.seconds),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
