import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class LocationResult {
  final String address;
  final double latitude;
  final double longitude;

  const LocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationSearchField extends StatefulWidget {
  final ValueChanged<LocationResult> onLocationSelected;
  final String? initialValue;

  const LocationSearchField({
    super.key,
    required this.onLocationSelected,
    this.initialValue,
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  late final FlutterGooglePlacesSdk _places;
  late final TextEditingController _controller;
  List<AutocompletePrediction> _predictions = [];
  bool _showPredictions = false;

  static const _malaysiaBias = LatLngBounds(
    southwest: LatLng(lat: 2.6, lng: 101.2),
    northeast: LatLng(lat: 3.9, lng: 102.0),
  );

  @override
  void initState() {
    super.initState();
    _places = FlutterGooglePlacesSdk(ApiConstants.googlePlacesApiKey);
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String query) async {
    if (query.length < 3) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    try {
      final result = await _places.findAutocompletePredictions(
        query,
        countries: ['MY'],
        locationBias: _malaysiaBias,
      );
      if (mounted) {
        setState(() {
          _predictions = result.predictions;
          _showPredictions = result.predictions.isNotEmpty;
        });
      }
    } catch (_) {
      // silently ignore autocomplete errors
    }
  }

  Future<void> _onPredictionSelected(AutocompletePrediction prediction) async {
    setState(() => _showPredictions = false);
    _controller.text = prediction.fullText;

    try {
      final result = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Location, PlaceField.Address],
      );
      final place = result.place;
      final latLng = place?.latLng;
      final address = place?.address ?? _controller.text;

      if (latLng != null) {
        widget.onLocationSelected(
          LocationResult(
            address: address,
            latitude: latLng.lat,
            longitude: latLng.lng,
          ),
        );
      }
    } catch (_) {
      // if place details fail, don't update — user can try again
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: AppStrings.searchLocation,
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _predictions = [];
                        _showPredictions = false;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        if (_showPredictions)
          Card(
            margin: const EdgeInsets.only(top: 4),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _predictions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.primary),
                  title: Text(
                    prediction.primaryText,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  subtitle: prediction.secondaryText.isNotEmpty
                      ? Text(
                          prediction.secondaryText,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        )
                      : null,
                  onTap: () => _onPredictionSelected(prediction),
                );
              },
            ),
          ),
      ],
    );
  }
}
