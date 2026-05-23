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
import '../../../session/domain/entities/participant_entity.dart';
import '../../../venue/presentation/pages/venues_page.dart';
import '../../../venue/presentation/widgets/best_pick_banner.dart';
import '../widgets/confirmed_venue_card.dart';
import '../widgets/vote_buttons.dart';
import '../widgets/voting_timer.dart';
import '../widgets/voting_winner_banner.dart';

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

// ── Stateful view — owns poll timer and UI transition state ───────────────────

class _SessionSummaryView extends StatefulWidget {
  final String shortCode;

  const _SessionSummaryView({required this.shortCode});

  @override
  State<_SessionSummaryView> createState() => _SessionSummaryViewState();
}

class _SessionSummaryViewState extends State<_SessionSummaryView> {
  Timer? _pollTimer;
  Timer? _recalculatingTimer;
  Timer? _loadingTimer;
  int _previousParticipantCount = 0;
  bool _isRecalculating = false;
  bool _votingActive = false;
  bool _isConfirmingVote = false;
  bool _isSlowLoad = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _startPolling(seconds: 10);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _recalculatingTimer?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startPolling({required int seconds}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (mounted) {
        context.read<CollaborationBloc>().add(
              GetSessionSummaryEvent(widget.shortCode, silent: true),
            );
      }
    });
  }

  void _onVotingExpired() {
    if (!mounted) return;
    setState(() => _isConfirmingVote = true);
    // Reload quickly while showing "Confirming..." banner
    _startPolling(seconds: 3);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isConfirmingVote = false);
      _startPolling(seconds: 10);
      context.read<CollaborationBloc>().add(
            GetSessionSummaryEvent(widget.shortCode),
          );
    });
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
          if (state is CollaborationLoading && !_hasLoaded) {
            setState(() => _isSlowLoad = false);
            _loadingTimer?.cancel();
            _loadingTimer = Timer(const Duration(seconds: 15), () {
              if (mounted) setState(() => _isSlowLoad = true);
            });
          }

          if (state is CollaborationError) {
            _loadingTimer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }

          SessionSummaryEntity? latestSummary;
          if (state is SessionSummaryLoaded) latestSummary = state.summary;
          if (state is VotingStarted) latestSummary = state.summary;

          if (latestSummary != null) {
            if (!_hasLoaded) {
              _hasLoaded = true;
              _loadingTimer?.cancel();
              if (_isSlowLoad) setState(() => _isSlowLoad = false);
            }

            final newCount = latestSummary.participants.length;
            if (newCount > _previousParticipantCount &&
                _previousParticipantCount > 0) {
              setState(() => _isRecalculating = true);
              _recalculatingTimer?.cancel();
              _recalculatingTimer = Timer(const Duration(seconds: 4), () {
                if (mounted) setState(() => _isRecalculating = false);
              });
            }
            _previousParticipantCount = newCount;

            final nowActive = latestSummary.votingState?.active ?? false;
            if (nowActive && !_votingActive) {
              _startPolling(seconds: 5);
            } else if (!nowActive && _votingActive && !_isConfirmingVote) {
              _startPolling(seconds: 10);
            }
            setState(() => _votingActive = nowActive);
          }
        },
        builder: (context, state) {
          if (state is CollaborationLoading || state is CollaborationInitial) {
            return _LoadingBody(
              isSlowLoad: _isSlowLoad,
              onRefresh: () async => context
                  .read<CollaborationBloc>()
                  .add(GetSessionSummaryEvent(widget.shortCode)),
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

          SessionSummaryEntity? activeSummary;
          if (state is SessionSummaryLoaded) activeSummary = state.summary;
          if (state is VotingStarted) activeSummary = state.summary;

          if (activeSummary != null) {
            return _SummaryBody(
              summary: activeSummary,
              shortCode: widget.shortCode,
              isRecalculating: _isRecalculating,
              isConfirmingVote: _isConfirmingVote,
              onShare: () => _share(activeSummary!),
              onCopyCode: () => _copyCode(context),
              onStartVoting: () => context
                  .read<CollaborationBloc>()
                  .add(StartVotingEvent(widget.shortCode)),
              onVotingExpired: _onVotingExpired,
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
  final bool isConfirmingVote;
  final VoidCallback onShare;
  final VoidCallback onCopyCode;
  final VoidCallback onStartVoting;
  final VoidCallback onVotingExpired;

  const _SummaryBody({
    required this.summary,
    required this.shortCode,
    required this.isRecalculating,
    required this.isConfirmingVote,
    required this.onShare,
    required this.onCopyCode,
    required this.onStartVoting,
    required this.onVotingExpired,
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
      isConfirmingVote: isConfirmingVote,
      onShare: onShare,
      onCopyCode: onCopyCode,
      onStartVoting: onStartVoting,
      onVotingExpired: onVotingExpired,
    );
  }
}

// ── State 1: Session in progress ─────────────────────────────────────────────

class _InProgressBody extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;
  final bool isRecalculating;
  final bool isConfirmingVote;
  final VoidCallback onShare;
  final VoidCallback onCopyCode;
  final VoidCallback onStartVoting;
  final VoidCallback onVotingExpired;

  const _InProgressBody({
    required this.summary,
    required this.shortCode,
    required this.isRecalculating,
    required this.isConfirmingVote,
    required this.onShare,
    required this.onCopyCode,
    required this.onStartVoting,
    required this.onVotingExpired,
  });

  bool get _isVotingActive => summary.votingState?.active ?? false;

  bool get _votingNeverStarted =>
      summary.votingState == null ||
      summary.votingState?.endsAt == null;

  bool get _hasMidpoint => summary.midpointLat != null;

  bool get _isWaiting => summary.participants.length == 1;

  bool get _showStartVoting =>
      _hasMidpoint &&
      !_isWaiting &&
      !_isVotingActive &&
      _votingNeverStarted;

  Map<String, String> get _participantNames => {
        for (final p in summary.participants) p.id: p.name ?? 'Anonymous',
      };

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context
          .read<CollaborationBloc>()
          .add(GetSessionSummaryEvent(shortCode)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Priority banners: confirming > voting timer > recalculating
          if (isConfirmingVote) ...[
            _ConfirmingBanner(),
            const SizedBox(height: 12),
          ] else if (_isVotingActive &&
              summary.votingState?.endsAt != null) ...[
            VotingTimer(
              endsAt: summary.votingState!.endsAt!,
              onExpired: onVotingExpired,
            ),
            const SizedBox(height: 12),
            VotingWinnerBanner(
              winningPlaceId: summary.votingState!.winningVenue,
              voteSummary: summary.voteSummary,
              venueNames: summary.venueNames,
            ),
            const SizedBox(height: 12),
          ] else if (isRecalculating) ...[
            _RecalculatingBanner(),
            const SizedBox(height: 12),
          ],

          _CodeCard(shortCode: shortCode, onCopy: onCopyCode, onShare: onShare),
          const SizedBox(height: 16),
          _ParticipantList(participants: summary.participants),
          const SizedBox(height: 16),

          if (_isWaiting) ...[
            // ── Waiting layout (1 participant) ──────────────────────────────
            _WaitingCard(),
            const SizedBox(height: 12),
            _SingleParticipantCard(participant: summary.participants.first),
            const SizedBox(height: 32),
          ] else ...[
            // ── Active layout (2+ participants / midpoint calculated) ────────
            if (summary.bestVenue != null) ...[
              BestPickBanner(
                venue: summary.bestVenue!,
                participantNames: _participantNames,
              ),
              const SizedBox(height: 12),
            ],
            _CompactVenueList(summary: summary, shortCode: shortCode),
            const SizedBox(height: 12),
            if (_showStartVoting) ...[
              _StartVotingButton(onStartVoting: onStartVoting),
              const SizedBox(height: 12),
            ],
            if (!_isVotingActive)
              _ConfirmButton(summary: summary, shortCode: shortCode),
            const SizedBox(height: 12),
            if (_hasMidpoint)
              _SeeAllVenuesButton(summary: summary, shortCode: shortCode),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}

class _ConfirmingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Confirming your meetup spot...',
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
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

class _StartVotingButton extends StatelessWidget {
  final VoidCallback onStartVoting;

  const _StartVotingButton({required this.onStartVoting});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollaborationBloc, CollaborationState>(
      builder: (context, state) {
        final loading = state is CollaborationLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onStartVoting,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.timer_outlined),
            label: const Text('Start Voting (5 min)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
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
          Icon(
            Icons.people_outline,
            size: 52,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'The best meetup spot will be calculated automatically as people join.',
            style: TextStyle(color: Colors.black38, fontSize: 12),
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
                Text(p.name ?? 'Anonymous',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactVenueList extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;

  const _CompactVenueList({required this.summary, required this.shortCode});

  List<({String placeId, String name})> get _topVenues {
    final venues = <({String placeId, String name})>[];

    // Best venue always first
    if (summary.bestVenue != null) {
      venues.add((placeId: summary.bestVenue!.placeId, name: summary.bestVenue!.name));
    }

    // Top voted venues (exclude best venue to avoid duplication)
    final sorted = summary.voteSummary.values.toList()
      ..sort((a, b) => b.upVotes.compareTo(a.upVotes));
    for (final v in sorted) {
      if (venues.length >= 3) break;
      if (venues.any((e) => e.placeId == v.placeId)) continue;
      venues.add((
        placeId: v.placeId,
        name: summary.venueNames[v.placeId] ?? v.placeId,
      ));
    }

    return venues;
  }

  @override
  Widget build(BuildContext context) {
    final venues = _topVenues;
    if (venues.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Spots',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...venues.map((v) {
          final voteData = summary.voteSummary[v.placeId];
          return _VenueRow(
            placeId: v.placeId,
            name: v.name,
            upCount: voteData?.upVotes ?? 0,
            downCount: voteData?.downVotes ?? 0,
            myVote: voteData?.myVote,
            shortCode: shortCode,
          );
        }),
      ],
    );
  }
}

class _VenueRow extends StatelessWidget {
  final String placeId;
  final String name;
  final int upCount;
  final int downCount;
  final String? myVote;
  final String shortCode;

  const _VenueRow({
    required this.placeId,
    required this.name,
    required this.upCount,
    required this.downCount,
    required this.shortCode,
    this.myVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          VoteButtons(
            placeId: placeId,
            venueName: name,
            upCount: upCount,
            downCount: downCount,
            currentVote: myVote,
            onVote: (vote) => context.read<CollaborationBloc>().add(
                  CastVoteEvent(
                    shortCode: shortCode,
                    placeId: placeId,
                    venueName: name,
                    vote: vote,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;

  const _ConfirmButton({required this.summary, required this.shortCode});

  String? get _placeId {
    if (summary.voteSummary.isNotEmpty) {
      return summary.voteSummary.values
          .reduce((a, b) => a.upVotes >= b.upVotes ? a : b)
          .placeId;
    }
    return summary.bestVenue?.placeId;
  }

  @override
  Widget build(BuildContext context) {
    final placeId = _placeId;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _SeeAllVenuesButton extends StatelessWidget {
  final SessionSummaryEntity summary;
  final String shortCode;

  const _SeeAllVenuesButton({required this.summary, required this.shortCode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VenuesPage(
              shortCode: shortCode,
              midpointLat: summary.midpointLat!,
              midpointLng: summary.midpointLng!,
              participantNames: {
                for (final p in summary.participants)
                  p.id: p.name ?? 'Anonymous',
              },
            ),
          ),
        ),
        icon: const Icon(Icons.explore_outlined),
        label: const Text('See All Venues'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _SingleParticipantCard extends StatelessWidget {
  final ParticipantEntity participant;

  const _SingleParticipantCard({required this.participant});

  @override
  Widget build(BuildContext context) {
    final initial = (participant.name ?? 'A')[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  participant.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
                      const Icon(Icons.person,
                          size: 16, color: Colors.black45),
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

class _LoadingBody extends StatelessWidget {
  final bool isSlowLoad;
  final Future<void> Function() onRefresh;

  const _LoadingBody({required this.isSlowLoad, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Finding the best spot for everyone... 🗺️',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: AppColors.primary),
                  if (isSlowLoad) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'This is taking longer than usual. Please wait...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pull down to refresh',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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
