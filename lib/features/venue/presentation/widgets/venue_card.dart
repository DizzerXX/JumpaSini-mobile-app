import 'package:flutter/material.dart';

import '../../domain/entities/venue_entity.dart';
import 'halal_badge.dart';
import 'travel_time_row.dart';

class VenueCard extends StatelessWidget {
  final VenueEntity venue;
  final VoidCallback onTap;
  final void Function(bool) onReportHalal;
  final Map<String, String> participantNames;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    required this.onReportHalal,
    this.participantNames = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VenuePhoto(photoUrl: venue.photoUrl, type: venue.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            venue.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (venue.isBestPick)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.shade600,
                              ),
                            ),
                            child: Text(
                              '⭐ Best',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        _MenuButton(onReportHalal: onReportHalal),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      venue.address,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (venue.rating != null) ...[
                          _StarRating(rating: venue.rating!),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '${(venue.distanceMeters / 1000).toStringAsFixed(1)} km away',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (venue.travelTimes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      TravelTimeRow(
                        travelTimes: venue.travelTimes,
                        participantNames: participantNames,
                      ),
                    ],
                    const SizedBox(height: 6),
                    HalalBadge(
                      isHalal: venue.isHalal,
                      isHalalVerified: venue.isHalalVerified,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenuePhoto extends StatelessWidget {
  final String? photoUrl;
  final String type;

  const _VenuePhoto({required this.photoUrl, required this.type});

  static const _typeEmoji = {
    'mall': '🏬',
    'restaurant': '🍽️',
    'cafe': '☕',
    'park': '🌳',
    'beach': '🏖️',
    'waterfall': '💧',
    'river': '🏞️',
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          _typeEmoji[type] ?? '📍',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < full) {
          icon = Icons.star;
        } else if (i == full && half) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: 14, color: Colors.amber);
      }),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final void Function(bool) onReportHalal;

  const _MenuButton({required this.onReportHalal});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.black45),
      itemBuilder: (_) => [
        const PopupMenuItem(value: true, child: Text('Report as Halal')),
        const PopupMenuItem(value: false, child: Text('Report as Not Halal')),
      ],
      onSelected: onReportHalal,
    );
  }
}
