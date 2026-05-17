import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class VenueTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onChanged;

  const VenueTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const _types = [
    (value: 'mall', label: AppStrings.mall, icon: Icons.local_mall),
    (value: 'restaurant', label: AppStrings.restaurant, icon: Icons.restaurant),
    (value: 'cafe', label: AppStrings.cafe, icon: Icons.local_cafe),
    (value: 'park', label: AppStrings.park, icon: Icons.park),
    (value: 'beach', label: AppStrings.beach, icon: Icons.beach_access),
    (value: 'waterfall', label: AppStrings.waterfall, icon: Icons.water),
    (value: 'river', label: AppStrings.river, icon: Icons.waves),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((type) {
        final selected = selectedType == type.value;
        return _VenueChip(
          label: type.label,
          icon: type.icon,
          selected: selected,
          onTap: () => onChanged(type.value),
        );
      }).toList(),
    );
  }
}

class _VenueChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VenueChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
