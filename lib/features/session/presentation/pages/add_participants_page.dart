import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/boundary_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/session_entity.dart';
import '../bloc/session_bloc.dart';
import '../widgets/location_search_field.dart';
import '../widgets/participant_card.dart';
import 'session_page.dart';

class AddParticipantsPage extends StatefulWidget {
  final SessionEntity session;

  const AddParticipantsPage({super.key, required this.session});

  @override
  State<AddParticipantsPage> createState() => _AddParticipantsPageState();
}

class _AddParticipantsPageState extends State<AddParticipantsPage> {
  final _nameController = TextEditingController();
  LocationResult? _selectedLocation;
  bool _fetchingLocation = false;

  late SessionEntity _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _showError(AppStrings.locationPermissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!BoundaryHelper.isWithinKLSelangor(position.latitude, position.longitude)) {
        _showError(AppStrings.locationOutsideBoundary);
        return;
      }

      setState(() {
        _selectedLocation = LocationResult(
          address: AppStrings.currentLocationLabel,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
    } catch (_) {
      _showError(AppStrings.locationUnavailable);
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _useTestLocation(String address, double lat, double lng) {
    setState(() {
      _selectedLocation = LocationResult(
        address: address,
        latitude: lat,
        longitude: lng,
      );
    });
  }

  void _addParticipant(BuildContext context) {
    final location = _selectedLocation;
    if (location == null) {
      _showError(AppStrings.addressRequired);
      return;
    }
    final nameError = Validators.name(_nameController.text);
    if (nameError != null) {
      _showError(nameError);
      return;
    }

    context.read<SessionBloc>().add(
          AddParticipantEvent(
            shortCode: _session.shortCode,
            name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
            address: location.address,
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.addParticipants),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is ParticipantAdded) {
            setState(() {
              _session = state.session;
              _selectedLocation = null;
              _nameController.clear();
            });
          } else if (state is SessionError) {
            _showError(state.message);
          }
        },
        child: Column(
          children: [
            _SessionCodeBanner(shortCode: _session.shortCode),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.addParticipantsSubtitle,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    if (_session.participants.isNotEmpty) ...[
                      Text(
                        '${_session.participantCount} ${AppStrings.participantsCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._session.participants.map(
                        (p) => ParticipantCard(participant: p),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (!_session.isFull) ...[
                      const Text(
                        'Add a location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.yourName,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LocationSearchField(
                        onLocationSelected: (result) =>
                            setState(() => _selectedLocation = result),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _fetchingLocation ? null : _useCurrentLocation,
                        icon: _fetchingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, color: AppColors.primary),
                        label: const Text(
                          AppStrings.useCurrentLocation,
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      if (kDebugMode)
                        _DebugLocationButtons(onSelect: _useTestLocation),
                      if (_selectedLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.success, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedLocation!.address,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.success,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      BlocBuilder<SessionBloc, SessionState>(
                        builder: (context, state) {
                          final loading = state is SessionLoading;
                          return SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: (_selectedLocation != null && !loading)
                                  ? () => _addParticipant(context)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      AppStrings.addParticipant,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ] else
                      _MaxReachedBanner(),
                  ],
                ),
              ),
            ),
            _BottomBar(session: _session),
          ],
        ),
      ),
    );
  }
}

class _SessionCodeBanner extends StatelessWidget {
  final String shortCode;

  const _SessionCodeBanner({required this.shortCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.share, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            '${AppStrings.sessionCode}: ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            shortCode,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxReachedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.maxParticipants,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final SessionEntity session;

  const _BottomBar({required this.session});

  @override
  Widget build(BuildContext context) {
    final canProceed = session.participantCount >= 2;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canProceed)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  AppStrings.minParticipants,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canProceed
                    ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => SessionPage(
                              shortCode: session.shortCode,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  AppStrings.findMeetupSpot,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugLocationButtons extends StatelessWidget {
  final void Function(String address, double lat, double lng) onSelect;

  static const _locations = [
    (label: 'KLCC', address: 'KLCC, Kuala Lumpur', lat: 3.1579, lng: 101.7119),
    (label: 'Subang Jaya', address: 'Subang Jaya, Selangor', lat: 3.0456, lng: 101.5797),
    (label: 'Petaling Jaya', address: 'Petaling Jaya, Selangor', lat: 3.1073, lng: 101.6067),
  ];

  const _DebugLocationButtons({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEBUG — Test locations',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _locations
                .map(
                  (loc) => ActionChip(
                    label: Text(loc.label, style: const TextStyle(fontSize: 12)),
                    onPressed: () => onSelect(loc.address, loc.lat, loc.lng),
                    backgroundColor: Colors.amber.shade100,
                    side: BorderSide(color: Colors.amber.shade400),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
