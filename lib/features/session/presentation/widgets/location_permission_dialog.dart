import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/permission_handler.dart';

class LocationPermissionDialog extends StatelessWidget {
  final bool isPermanentlyDenied;

  const LocationPermissionDialog({
    super.key,
    required this.isPermanentlyDenied,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Access Needed',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'JumpaSini needs your location to suggest the fairest meetup spot for everyone.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (isPermanentlyDenied) {
                await Geolocator.openAppSettings();
                if (context.mounted) Navigator.of(context).pop(false);
              } else {
                final granted =
                    await LocationPermissionHandler.requestLocationPermission();
                if (context.mounted) Navigator.of(context).pop(granted);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isPermanentlyDenied ? 'Open Settings' : 'Allow Location',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Skip for now',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
