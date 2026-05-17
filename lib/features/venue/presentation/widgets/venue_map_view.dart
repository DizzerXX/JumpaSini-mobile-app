import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/venue_entity.dart';

class VenueMapView extends StatefulWidget {
  final List<VenueEntity> venues;
  final double midpointLat;
  final double midpointLng;

  const VenueMapView({
    super.key,
    required this.venues,
    required this.midpointLat,
    required this.midpointLng,
  });

  @override
  State<VenueMapView> createState() => _VenueMapViewState();
}

class _VenueMapViewState extends State<VenueMapView> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void didUpdateWidget(VenueMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.venues != widget.venues) {
      _buildMarkers();
    }
  }

  void _buildMarkers() {
    final markers = <Marker>{};

    // Midpoint marker
    markers.add(
      Marker(
        markerId: const MarkerId('midpoint'),
        position: LatLng(widget.midpointLat, widget.midpointLng),
        infoWindow: const InfoWindow(title: 'Meeting Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Venue markers
    for (final venue in widget.venues) {
      markers.add(
        Marker(
          markerId: MarkerId(venue.placeId),
          position: LatLng(venue.lat, venue.lng),
          infoWindow: InfoWindow(
            title: venue.name,
            snippet: '${(venue.distanceMeters / 1000).toStringAsFixed(1)} km away',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            venue.isBestPick
                ? BitmapDescriptor.hueYellow
                : BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    setState(() => _markers
      ..clear()
      ..addAll(markers));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.midpointLat, widget.midpointLng),
        zoom: 13,
      ),
      markers: _markers,
      onMapCreated: (controller) => _controller = controller,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
