import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/places_remote_datasource.dart';

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
  static const _debounce = Duration(milliseconds: 300);
  static const _uuid = Uuid();

  late final PlacesRemoteDatasource _places;
  late final TextEditingController _controller;

  List<PlaceSuggestion> _predictions = [];
  bool _showPredictions = false;
  bool _isResolving = false;
  Timer? _debounceTimer;

  /// Groups this user's keystrokes plus the final details call into one billable
  /// Google autocomplete session. Regenerated once a place is resolved.
  String _sessionToken = _uuid.v4();

  @override
  void initState() {
    super.initState();
    _places = sl<PlacesRemoteDatasource>();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < 3) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    // Debounced so a typed word costs one proxied request rather than one per key.
    _debounceTimer = Timer(_debounce, () => _fetchPredictions(query));
  }

  Future<void> _fetchPredictions(String query) async {
    try {
      final results = await _places.autocomplete(
        query,
        sessionToken: _sessionToken,
      );

      if (!mounted) return;

      setState(() {
        _predictions = results;
        _showPredictions = results.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
    }
  }

  Future<void> _onPredictionSelected(PlaceSuggestion prediction) async {
    setState(() {
      _showPredictions = false;
      _isResolving = true;
    });
    _controller.text = prediction.fullText;

    try {
      final place = await _places.details(
        prediction.placeId,
        sessionToken: _sessionToken,
      );

      // The autocomplete session ends once a place has been resolved.
      _sessionToken = _uuid.v4();

      widget.onLocationSelected(
        LocationResult(
          address: place.address.isNotEmpty ? place.address : prediction.fullText,
          latitude: place.latitude,
          longitude: place.longitude,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not resolve that address. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
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
            suffixIcon: _buildSuffixIcon(),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
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

  Widget? _buildSuffixIcon() {
    if (_isResolving) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_controller.text.isEmpty) return null;

    return IconButton(
      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
      onPressed: () {
        _controller.clear();
        setState(() {
          _predictions = [];
          _showPredictions = false;
        });
      },
    );
  }
}
