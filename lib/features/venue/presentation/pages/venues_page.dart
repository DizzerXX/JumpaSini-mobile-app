import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/venue_entity.dart';
import '../bloc/venue_bloc.dart';
import '../widgets/halal_badge.dart';
import '../widgets/venue_card.dart';
import '../widgets/venue_map_view.dart';

class VenuesPage extends StatelessWidget {
  final String shortCode;
  final double midpointLat;
  final double midpointLng;

  const VenuesPage({
    super.key,
    required this.shortCode,
    required this.midpointLat,
    required this.midpointLng,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VenueBloc>()..add(LoadVenuesEvent(shortCode)),
      child: _VenuesView(
        shortCode: shortCode,
        midpointLat: midpointLat,
        midpointLng: midpointLng,
      ),
    );
  }
}

class _VenuesView extends StatefulWidget {
  final String shortCode;
  final double midpointLat;
  final double midpointLng;

  const _VenuesView({
    required this.shortCode,
    required this.midpointLat,
    required this.midpointLng,
  });

  @override
  State<_VenuesView> createState() => _VenuesViewState();
}

class _VenuesViewState extends State<_VenuesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _halalOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleHalal(BuildContext context) {
    setState(() => _halalOnly = !_halalOnly);
    context.read<VenueBloc>().add(
          FilterVenuesEvent(_halalOnly ? true : null),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Best Meetup Spots'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: _halalOnly ? Colors.yellow : Colors.white,
            ),
            tooltip: 'Halal filter',
            onPressed: () => _toggleHalal(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'List View'),
            Tab(text: 'Map View'),
          ],
        ),
      ),
      body: BlocConsumer<VenueBloc, VenueState>(
        listener: (context, state) {
          if (state is HalalReportSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted. Thank you!')),
            );
          } else if (state is VenueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (_halalOnly)
                Container(
                  color: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Halal Only',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ListTab(
                      state: state,
                      shortCode: widget.shortCode,
                    ),
                    _MapTab(
                      state: state,
                      midpointLat: widget.midpointLat,
                      midpointLng: widget.midpointLng,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  final VenueState state;
  final String shortCode;

  const _ListTab({required this.state, required this.shortCode});

  @override
  Widget build(BuildContext context) {
    if (state is VenueLoading) {
      return _ShimmerList();
    }

    if (state is VenueError) {
      return Center(
        child: Text(
          (state as VenueError).message,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final venues = state is VenuesLoaded
        ? (state as VenuesLoaded).filteredVenues
        : <VenueEntity>[];

    if (venues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No venues found. Try a different venue type.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VenueBloc>().add(LoadVenuesEvent(shortCode));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: venues.length,
        itemBuilder: (context, index) {
          final venue = venues[index];
          return VenueCard(
            venue: venue,
            onTap: () => _showVenueDetail(context, venue, shortCode),
            onReportHalal: (isHalal) {
              context.read<VenueBloc>().add(
                    ReportHalalEvent(
                      placeId: venue.placeId,
                      isHalal: isHalal,
                      shortCode: shortCode,
                    ),
                  );
            },
          );
        },
      ),
    );
  }
}

class _MapTab extends StatelessWidget {
  final VenueState state;
  final double midpointLat;
  final double midpointLng;

  const _MapTab({
    required this.state,
    required this.midpointLat,
    required this.midpointLng,
  });

  @override
  Widget build(BuildContext context) {
    if (state is! VenuesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final venues = (state as VenuesLoaded).filteredVenues;

    return VenueMapView(
      venues: venues,
      midpointLat: midpointLat,
      midpointLng: midpointLng,
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 3,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const SizedBox(height: 96),
        ),
      ),
    );
  }
}

void _showVenueDetail(BuildContext context, VenueEntity venue, String shortCode) {
  final bloc = context.read<VenueBloc>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _VenueDetailSheet(venue: venue, shortCode: shortCode),
    ),
  );
}

class _VenueDetailSheet extends StatelessWidget {
  final VenueEntity venue;
  final String shortCode;

  const _VenueDetailSheet({required this.venue, required this.shortCode});

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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (rating != null) ...[
                        Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.directions_walk, size: 16, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        '$distanceKm km away',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
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
                            side: const BorderSide(color: AppColors.success),
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
