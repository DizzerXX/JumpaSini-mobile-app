import 'package:flutter/material.dart';

import '../../domain/entities/participant_entity.dart';
import '../../../../core/constants/app_colors.dart';

class ParticipantCard extends StatelessWidget {
  final ParticipantEntity participant;
  final bool canRemove;
  final VoidCallback? onRemove;

  const ParticipantCard({
    super.key,
    required this.participant,
    this.canRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          participant.name ?? 'Anonymous',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          participant.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: canRemove
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                onPressed: onRemove,
                tooltip: 'Remove participant',
              )
            : null,
      ),
    );
  }

  String get _initials {
    final name = participant.name;
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
