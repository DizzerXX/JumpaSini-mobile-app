import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class TransportModeSelector extends StatelessWidget {
  final String? selectedMode;
  final ValueChanged<String> onChanged;

  const TransportModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  static const _modes = [
    (value: 'car', label: AppStrings.car, icon: Icons.directions_car),
    (value: 'public_transport', label: AppStrings.publicTransport, icon: Icons.directions_bus),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _modes.map((mode) {
        final selected = selectedMode == mode.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ModeChip(
              label: mode.label,
              icon: mode.icon,
              selected: selected,
              onTap: () => onChanged(mode.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
