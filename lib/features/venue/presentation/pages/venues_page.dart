import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../collaboration/presentation/bloc/collaboration_bloc.dart';
import '../../domain/entities/venue_entity.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/venue_bloc.dart';
import '../widgets/venue_card.dart';
import '../widgets/venue_detail_sheet.dart';
import '../widgets/venue_map_view.dart';
import '../widgets/weather_banner.dart';

class VenuesPage extends StatelessWidget {
  final String shortCode;
  final double midpointLat;
  final double midpointLng;
  final Map<String, String> participantNames;

  const VenuesPage({
    super.key,
    required this.shortCode,
    required this.midpointLat,
    required this.midpointLng,
    this.participantNames = const {},
  });

  @override
  Widget build(BuildContext context) {
    return _VenuesView(
      shortCode: shortCode,
      midpointLat: midpointLat,
      midpointLng: midpointLng,
      participantNames: participantNames,
    );
  }
}

class _VenuesView extends StatefulWidget {
  final String shortCode;
  final double midpointLat;
  final double midpointLng;
  final Map<String, String> participantNames;

  const _VenuesView({
    required this.shortCode,
    required this.midpointLat,
    required this.midpointLng,
    required this.participantNames,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final venueBloc = context.read<VenueBloc>();
      if (venueBloc.state is! VenuesLoaded && venueBloc.state is! VenueLoading) {
        venueBloc.add(LoadVenuesEvent(widget.shortCode));
      }
      // Weather has its own bloc — loading it can no longer wipe the venue list.
      context.read<WeatherBloc>().add(LoadWeatherEvent(widget.shortCode));
    });
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
      body: BlocListener<VenueBloc, VenueState>(
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
        child: Column(
          children: [
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) => state is WeatherLoaded
                  ? WeatherBanner(assessment: state.assessment)
                  : const SizedBox.shrink(),
            ),
            if (_halalOnly)
              Container(
                color: AppColors.primaryLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.primary, size: 16),
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
                    shortCode: widget.shortCode,
                    participantNames: widget.participantNames,
                  ),
                  _MapTab(
                    midpointLat: widget.midpointLat,
                    midpointLng: widget.midpointLng,
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

class _ListTab extends StatefulWidget {
  final String shortCode;
  final Map<String, String> participantNames;

  const _ListTab({
    required this.shortCode,
    required this.participantNames,
  });

  @override
  State<_ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<_ListTab>
    with AutomaticKeepAliveClientMixin {
  List<VenueEntity> _lastVenues = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        if (state is VenuesLoaded) {
          _lastVenues = state.filteredVenues;
        }

        if (_lastVenues.isEmpty) {
          if (state is VenueLoading || state is VenueInitial) {
            return _ShimmerList();
          }
          if (state is VenueError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
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

        final venues = _lastVenues;
        final hasBestPick = venues.isNotEmpty && venues[0].isBestPick;
        final items = <Widget>[];

        if (hasBestPick) {
          items.add(const _SectionHeader('Recommended ⭐'));
          items.add(_buildCard(context, venues[0]));
          if (venues.length > 1) {
            items.add(const _SectionHeader('Other Options'));
            for (var i = 1; i < venues.length; i++) {
              items.add(_buildCard(context, venues[i]));
            }
          }
        } else {
          for (final venue in venues) {
            items.add(_buildCard(context, venue));
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<VenueBloc>().add(LoadVenuesEvent(widget.shortCode));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: items,
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, VenueEntity venue) {
    return VenueCard(
      venue: venue,
      participantNames: widget.participantNames,
      onTap: () => _showVenueDetail(context, venue, widget.shortCode),
      onReportHalal: (isHalal) {
        context.read<VenueBloc>().add(
              ReportHalalEvent(
                placeId: venue.placeId,
                isHalal: isHalal,
                shortCode: widget.shortCode,
              ),
            );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MapTab extends StatefulWidget {
  final double midpointLat;
  final double midpointLng;

  const _MapTab({
    required this.midpointLat,
    required this.midpointLng,
  });

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab>
    with AutomaticKeepAliveClientMixin {
  List<VenueEntity> _lastVenues = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        if (state is VenuesLoaded) {
          _lastVenues = state.filteredVenues;
        }

        if (_lastVenues.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return VenueMapView(
          venues: _lastVenues,
          midpointLat: widget.midpointLat,
          midpointLng: widget.midpointLng,
        );
      },
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const SizedBox(height: 96),
        ),
      ),
    );
  }
}

CollaborationBloc? _tryReadCollab(BuildContext context) {
  try {
    return context.read<CollaborationBloc>();
  } catch (_) {
    return null;
  }
}

void _showVenueDetail(
  BuildContext context,
  VenueEntity venue,
  String shortCode,
) {
  final venueBloc = context.read<VenueBloc>();
  final collabBloc = _tryReadCollab(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      final sheet = VenueDetailSheet(
        venue: venue,
        shortCode: shortCode,
        showVoteButtons: collabBloc != null,
      );
      if (collabBloc != null) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: venueBloc),
            BlocProvider.value(value: collabBloc),
          ],
          child: sheet,
        );
      }
      return BlocProvider.value(value: venueBloc, child: sheet);
    },
  );
}
