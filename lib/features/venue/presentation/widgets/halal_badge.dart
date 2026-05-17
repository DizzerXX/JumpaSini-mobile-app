import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class HalalBadge extends StatelessWidget {
  final bool? isHalal;
  final bool isHalalVerified;

  const HalalBadge({
    super.key,
    required this.isHalal,
    required this.isHalalVerified,
  });

  @override
  Widget build(BuildContext context) {
    if (isHalal == null) return const SizedBox.shrink();

    final verified = isHalalVerified && isHalal == true;
    final label = verified
        ? '✓ JAKIM Verified'
        : isHalal == true
            ? 'Halal'
            : 'Not Halal';

    final color = isHalal == true ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verified ? AppColors.primary : color,
          width: verified ? 1.5 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: verified ? AppColors.primary : color,
        ),
      ),
    );
  }
}
