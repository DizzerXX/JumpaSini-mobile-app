import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/venue_entity.dart';
import 'halal_badge.dart';
import 'travel_time_row.dart';

class BestPickBanner extends StatelessWidget {
  final VenueEntity venue;
  final Map<String, String> participantNames;

  const BestPickBanner({
    super.key,
    required this.venue,
    required this.participantNames,
  });

  Future<void> _openDirections() async {
    final uri = Uri.parse(venue.googleMapsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = (venue.distanceMeters / 1000).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withAlpha(51),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Best Pick label
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⭐ Best Pick',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Venue name
            Text(
              venue.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3000),
              ),
            ),
            const SizedBox(height: 4),

            // Address
            Text(
              venue.address,
              style: const TextStyle(
                color: Color(0xFF7A6030),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),

            // Rating + distance row
            Row(
              children: [
                if (venue.rating != null) ...[
                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    venue.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A3000),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFF7A6030),
                ),
                const SizedBox(width: 4),
                Text(
                  '$distanceKm km from midpoint',
                  style: const TextStyle(
                    color: Color(0xFF7A6030),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Halal badge
            HalalBadge(
              isHalal: venue.isHalal,
              isHalalVerified: venue.isHalalVerified,
            ),

            // Travel times
            if (venue.travelTimes.isNotEmpty) ...[
              const SizedBox(height: 10),
              TravelTimeRow(
                travelTimes: venue.travelTimes,
                participantNames: participantNames,
              ),
            ],

            const SizedBox(height: 14),

            // Get Directions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
