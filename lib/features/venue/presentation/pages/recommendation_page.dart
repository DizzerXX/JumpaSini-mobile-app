import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../collaboration/presentation/bloc/collaboration_bloc.dart';
import '../../../collaboration/presentation/bloc/collaboration_event.dart';
import '../../../collaboration/presentation/bloc/collaboration_state.dart';
import '../../../collaboration/presentation/pages/session_summary_page.dart';
import '../../../collaboration/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/recommendation_entity.dart';
import '../../domain/entities/travel_time.dart';
import '../../domain/entities/venue_entity.dart';
import '../bloc/venue_bloc.dart';
import '../widgets/best_pick_banner.dart';
import '../widgets/travel_time_row.dart';
import '../widgets/venue_detail_sheet.dart';
import 'venues_page.dart';

class RecommendationPage extends StatelessWidget {
  final RecommendationEntity recommendation;
  final String shortCode;
  final double midpointLat;
  final double midpointLng;

  const RecommendationPage({
    super.key,
    required this.recommendation,
    required this.shortCode,
    required this.midpointLat,
    required this.midpointLng,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<VenueBloc>()..add(LoadVenuesEvent(shortCode)),
        ),
        BlocProvider(
          create: (_) => sl<CollaborationBloc>()
            ..add(GetVotesEvent(shortCode)),
        ),
      ],
      child: _RecommendationView(
        recommendation: recommendation,
        shortCode: shortCode,
        midpointLat: midpointLat,
        midpointLng: midpointLng,
      ),
    );
  }
}

class _RecommendationView extends StatelessWidget {
  final RecommendationEntity recommendation;
  final String shortCode;
  final double midpointLat;
  final double midpointLng;

  const _RecommendationView({
    required this.recommendation,
    required this.shortCode,
    required this.midpointLat,
    required this.midpointLng,
  });

  Map<String, String> get _participantNames => {
        for (final p in recommendation.participantSummary)
          p.participantId: p.name,
      };

  Color _fairnessColor(double score) {
    if (score > 0.7) return Colors.green;
    if (score >= 0.4) return Colors.amber.shade700;
    return Colors.red;
  }

  void _share(BuildContext context) {
    Share.share(
      'Join my JumpaSini session!\n'
      'Code: $shortCode\n'
      'Open: ${ApiConstants.webAppUrl}/session/$shortCode',
    );
  }

  @override
  Widget build(BuildContext context) {
    final names = _participantNames;
    final fairness = recommendation.fairnessScore;
    final percent = (fairness * 100).round();
    final color = _fairnessColor(fairness);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Meetup Spot'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Session hub',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SessionSummaryPage(shortCode: shortCode),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _share(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Best pick banner with vote buttons
            BlocBuilder<CollaborationBloc, CollaborationState>(
              builder: (context, collab) {
                final voteSummary =
                    collab is VotesLoaded ? collab.voteSummary : {};
                final voteData =
                    voteSummary[recommendation.bestVenue.placeId];
                final currentVote =
                    collab is VoteCast &&
                            collab.voteSummary
                                .containsKey(recommendation.bestVenue.placeId)
                        ? collab.myVote
                        : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BestPickBanner(
                      venue: recommendation.bestVenue,
                      participantNames: names,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: VoteButtons(
                        placeId: recommendation.bestVenue.placeId,
                        venueName: recommendation.bestVenue.name,
                        currentVote: currentVote,
                        upCount: voteData?.upVotes ?? 0,
                        downCount: voteData?.downVotes ?? 0,
                        onVote: (vote) =>
                            context.read<CollaborationBloc>().add(
                                  CastVoteEvent(
                                    shortCode:  shortCode,
                                    placeId:    recommendation.bestVenue.placeId,
                                    venueName:  recommendation.bestVenue.name,
                                    vote:       vote,
                                  ),
                                ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Other Options',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Horizontal list of other venues
            BlocBuilder<VenueBloc, VenueState>(
              builder: (context, state) {
                if (state is VenueLoading) {
                  return const SizedBox(
                    height: 140,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is VenuesLoaded) {
                  final others = state.venues
                      .where(
                        (v) => v.placeId != recommendation.bestVenue.placeId,
                      )
                      .take(4)
                      .toList();
                  if (others.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 210,
                    child: BlocBuilder<CollaborationBloc, CollaborationState>(
                      builder: (context, collab) {
                        final voteSummary =
                            collab is VotesLoaded ? collab.voteSummary : {};
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: others.length,
                          itemBuilder: (ctx, i) => _CompactVenueCard(
                            venue: others[i],
                            participantNames: names,
                            shortCode: shortCode,
                            voteSummary: voteSummary,
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // See All on Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  final venueBloc = context.read<VenueBloc>();
                  final collabBloc = context.read<CollaborationBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: venueBloc),
                          BlocProvider.value(value: collabBloc),
                        ],
                        child: VenuesPage(
                          shortCode: shortCode,
                          midpointLat: midpointLat,
                          midpointLng: midpointLng,
                          participantNames: names,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('See All on Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Fairness indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trip Fairness',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$percent% balanced',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fairness.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 12,
                    ),
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

class _CompactVenueCard extends StatelessWidget {
  final VenueEntity venue;
  final Map<String, String> participantNames;
  final String shortCode;
  final Map voteSummary;

  const _CompactVenueCard({
    required this.venue,
    required this.participantNames,
    required this.shortCode,
    required this.voteSummary,
  });

  void _showDetail(BuildContext context) {
    final venueBloc = context.read<VenueBloc>();
    final collabBloc = context.read<CollaborationBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: venueBloc),
          BlocProvider.value(value: collabBloc),
        ],
        child: VenueDetailSheet(
          venue: venue,
          shortCode: shortCode,
          showVoteButtons: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voteData = voteSummary[venue.placeId];
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (venue.rating != null)
              Row(
                children: [
                  Icon(Icons.star, size: 13, color: Colors.amber.shade600),
                  const SizedBox(width: 3),
                  Text(
                    venue.rating!.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            const SizedBox(height: 2),
            Text(
              '${(venue.distanceMeters / 1000).toStringAsFixed(1)} km away',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            if (venue.travelTimes.isNotEmpty) ...[
              const SizedBox(height: 6),
              _MiniTravelTimes(
                travelTimes: venue.travelTimes,
                participantNames: participantNames,
              ),
            ],
            const SizedBox(height: 8),
            VoteButtons(
              placeId: venue.placeId,
              venueName: venue.name,
              upCount: voteData?.upVotes ?? 0,
              downCount: voteData?.downVotes ?? 0,
              onVote: (vote) => context.read<CollaborationBloc>().add(
                    CastVoteEvent(
                      shortCode: shortCode,
                      placeId:   venue.placeId,
                      venueName: venue.name,
                      vote:      vote,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTravelTimes extends StatelessWidget {
  final Map<String, TravelTime> travelTimes;
  final Map<String, String> participantNames;

  const _MiniTravelTimes({
    required this.travelTimes,
    required this.participantNames,
  });

  @override
  Widget build(BuildContext context) {
    return TravelTimeRow(
      travelTimes: travelTimes,
      participantNames: participantNames,
    );
  }
}
