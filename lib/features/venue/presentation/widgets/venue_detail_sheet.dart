import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../collaboration/presentation/bloc/collaboration_bloc.dart';
import '../../../collaboration/presentation/bloc/collaboration_event.dart';
import '../../../collaboration/presentation/bloc/collaboration_state.dart';
import '../../../collaboration/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/venue_entity.dart';
import '../bloc/venue_bloc.dart';
import 'halal_badge.dart';

class VenueDetailSheet extends StatelessWidget {
  final VenueEntity venue;
  final String shortCode;
  final bool showVoteButtons;

  const VenueDetailSheet({
    super.key,
    required this.venue,
    required this.shortCode,
    this.showVoteButtons = false,
  });

  Future<void> _openDirections() async {
    final uri = Uri.parse(venue.googleMapsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final rating = venue.rating;
    final distanceKm = (venue.distanceMeters / 1000).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (venue.photoUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  venue.photoUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    venue.address,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (rating != null) ...[
                        Icon(Icons.star,
                            size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.directions_walk,
                          size: 16, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        '$distanceKm km away',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  HalalBadge(
                    isHalal: venue.isHalal,
                    isHalalVerified: venue.isHalalVerified,
                  ),
                  const Divider(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openDirections,
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (showVoteButtons) ...[
                    const SizedBox(height: 10),
                    BlocBuilder<CollaborationBloc, CollaborationState>(
                      builder: (context, state) {
                        final voteSummary = switch (state) {
                          VotesLoaded() => state.voteSummary,
                          VoteCast() => state.voteSummary,
                          SessionSummaryLoaded() =>
                            state.summary.voteSummary,
                          VotingStarted() => state.summary.voteSummary,
                          _ => const {},
                        };
                        final voteData = voteSummary[venue.placeId];
                        final currentVote = state is VoteCast &&
                                state.voteSummary
                                    .containsKey(venue.placeId)
                            ? state.myVote
                            : voteData?.myVote;
                        return VoteButtons(
                          placeId: venue.placeId,
                          venueName: venue.name,
                          upCount: voteData?.upVotes ?? 0,
                          downCount: voteData?.downVotes ?? 0,
                          currentVote: currentVote,
                          onVote: (vote) =>
                              context.read<CollaborationBloc>().add(
                                    CastVoteEvent(
                                      shortCode: shortCode,
                                      placeId: venue.placeId,
                                      venueName: venue.name,
                                      vote: vote,
                                    ),
                                  ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<VenueBloc>().add(ReportHalalEvent(
                                  placeId: venue.placeId,
                                  isHalal: true,
                                  shortCode: shortCode,
                                ));
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.success),
                            foregroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Report Halal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<VenueBloc>().add(ReportHalalEvent(
                                  placeId: venue.placeId,
                                  isHalal: false,
                                  shortCode: shortCode,
                                ));
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            foregroundColor: AppColors.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Report Not Halal'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
