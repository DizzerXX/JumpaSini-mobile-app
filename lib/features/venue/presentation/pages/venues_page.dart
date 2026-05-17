import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/venue_entity.dart';
import '../bloc/venue_bloc.dart';
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
            onTap: () {},
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
