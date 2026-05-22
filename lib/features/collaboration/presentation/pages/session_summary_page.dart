import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../session/presentation/pages/home_page.dart';
import '../../domain/entities/session_summary_entity.dart';
import '../bloc/collaboration_bloc.dart';
import '../bloc/collaboration_event.dart';
import '../bloc/collaboration_state.dart';
import '../widgets/confirmed_venue_card.dart';
import '../widgets/vote_tally.dart';

class SessionSummaryPage extends StatelessWidget {
  final String shortCode;

  const SessionSummaryPage({super.key, required this.shortCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CollaborationBloc>()..add(GetSessionSummaryEvent(shortCode)),
      child: _SessionSummaryView(shortCode: shortCode),
    );
  }
}

// ── Stateful view — owns polling timer and recalculating state ────────────────

class _SessionSummaryView extends StatefulWidget {
  final String shortCode;

  const _SessionSummaryView({required this.shortCode});

  @override
  State<_SessionSummaryView> createState() => _SessionSummaryViewState();
}

class _SessionSummaryViewState extends State<_SessionSummaryView> {
  Timer? _pollTimer;
  Timer? _recalculatingTimer;
  int _previousParticipantCount = 0;
  bool _isRecalculating = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        context.read<CollaborationBloc>().add(
              GetSessionSummaryEvent(widget.shortCode, silent: true),
            );
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _recalculatingTimer?.cancel();
    super.dispose();
  }

  void _share(SessionSummaryEntity summary) {
    final url = summary.session.shareableUrl ??
        '${ApiConstants.webAppUrl}/session/${widget.shortCode}';
    Share.share(
      'Join my JumpaSini session! Code: ${widget.shortCode}\n'
      'Or open: $url',
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.shortCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session code copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          if (state is CollaborationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is SessionSummaryLoaded) {
            final newCount = state.summary.participants.length;
            if (newCount > _previousParticipantCount &&
                _previousParticipantCount > 0) {
              setState(() => _isRecalculating = true);
              _recalculatingTimer?.cancel();
              _recalculatingTimer = Timer(const Duration(seconds: 4), () {
                if (mounted) setState(() => _isRecalculating = false);
              });
            }
            _previousParticipantCount = newCount;
          }
        },
        builder: (context, state) {
          if (state is CollaborationLoading || state is CollaborationInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CollaborationError && _previousParticipantCount == 0) {
            return _ErrorBody(
              message: state.message,
              onRetry: () => context
                  .read<CollaborationBloc>()
                  .add(GetSessionSummaryEvent(widget.shortCode)),
            );
          }

          if (state is SessionSummaryLoaded) {
            return _SummaryBody(
              summary: state.summary,
              shortCode: widget.shortCode,
              isRecalculating: _isRecalculating,
              onShare: () => _share(state.summary),
              onCopyCode: () => _copyCode(context),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;
  final bool isRecalculating;
  final VoidCallback onShare;
  final VoidCallback onCopyCode;

  const _SummaryBody({
    required this.summary,
    required this.shortCode,
    required this.isRecalculating,
    required this.onShare,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isComplete && summary.confirmedVenue != null) {
      return _CompletedBody(summary: summary);
    }
    return _InProgressBody(
      summary: summary,
      shortCode: shortCode,
      isRecalculating: isRecalculating,
      onShare: onShare,
      onCopyCode: onCopyCode,
    );
  }
}

// ── State 1: Session in progress ─────────────────────────────────────────────

class _InProgressBody extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;
  final bool isRecalculating;
  final VoidCallback onShare;
  final VoidCallback onCopyCode;

  const _InProgressBody({
    required this.summary,
    required this.shortCode,
    required this.isRecalculating,
    required this.onShare,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context) {
    final isWaiting = summary.participants.length == 1;

    return RefreshIndicator(
      onRefresh: () async => context
          .read<CollaborationBloc>()
          .add(GetSessionSummaryEvent(shortCode)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isRecalculating) ...[
            _RecalculatingBanner(),
            const SizedBox(height: 12),
          ],
          _CodeCard(
            shortCode: shortCode,
            onCopy: onCopyCode,
            onShare: onShare,
          ),
          const SizedBox(height: 20),
          _ParticipantList(participants: summary.participants),
          const SizedBox(height: 20),
          if (isWaiting) ...[
            _WaitingCard(),
            const SizedBox(height: 20),
          ] else ...[
            _VoteSection(summary: summary),
            const SizedBox(height: 20),
            _ConfirmButton(summary: summary, shortCode: shortCode),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}

class _RecalculatingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.recalculatingSpots,
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 52, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          const Text(
            AppStrings.waitingForOthers,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Share the session code above so friends can join from their device.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'The best meetup spot will be calculated automatically as people join.',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String shortCode;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _CodeCard({
    required this.shortCode,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Text(
            'Your Session Code',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                shortCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: onCopy,
                color: AppColors.primary,
                tooltip: 'Copy code',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Share this code with friends',
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('Share Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantList extends StatelessWidget {
  final List participants;

  const _ParticipantList({required this.participants});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${participants.length} ${participants.length == 1 ? 'person' : 'people'} in this session',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...participants.map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.black45),
                const SizedBox(width: 8),
                Text(p.name ?? 'Anonymous', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VoteSection extends StatelessWidget {
  final SessionSummaryEntity summary;

  const _VoteSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.voteSummary.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vote Tally',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        VoteTally(voteSummary: summary.voteSummary),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;

  const _ConfirmButton({required this.summary, required this.shortCode});

  String? get _topVenuePlaceId {
    if (summary.voteSummary.isEmpty) return null;
    return summary.voteSummary.values
        .reduce((a, b) => a.upVotes >= b.upVotes ? a : b)
        .placeId;
  }

  @override
  Widget build(BuildContext context) {
    final placeId = _topVenuePlaceId;
    if (placeId == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.read<CollaborationBloc>().add(
              ConfirmVenueEvent(shortCode: shortCode, placeId: placeId),
            ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Confirm Meetup Spot'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ── State 2: Session completed ────────────────────────────────────────────────

class _CompletedBody extends StatelessWidget {
  final SessionSummaryEntity summary;

  const _CompletedBody({required this.summary});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        ConfirmedVenueCard(venue: summary.confirmedVenue!),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Add to Calendar (coming soon)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black45,
              side: const BorderSide(color: Colors.black26),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${summary.participants.length} ${summary.participants.length == 1 ? 'person' : 'people'} in this session',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ...summary.participants.map(
                (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.black45),
                      const SizedBox(width: 8),
                      Text(
                        p.name ?? 'Anonymous',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
              (_) => false,
            ),
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Start New Meetup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
