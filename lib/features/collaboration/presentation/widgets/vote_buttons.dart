import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class VoteButtons extends StatelessWidget {
  final String placeId;
  final String venueName;
  final String? currentVote;
  final void Function(String vote) onVote;
  final int upCount;
  final int downCount;

  const VoteButtons({
    super.key,
    required this.placeId,
    required this.venueName,
    required this.onVote,
    this.currentVote,
    this.upCount = 0,
    this.downCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoteChip(
          label: '👍 $upCount',
          isActive: currentVote == 'up',
          onTap: currentVote == 'up' ? null : () => onVote('up'),
        ),
        const SizedBox(width: 8),
        _VoteChip(
          label: '👎 $downCount',
          isActive: currentVote == 'down',
          onTap: currentVote == 'down' ? null : () => onVote('down'),
        ),
      ],
    );
  }
}

class _VoteChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _VoteChip({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
