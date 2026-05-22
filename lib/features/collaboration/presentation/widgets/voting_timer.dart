import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class VotingTimer extends StatefulWidget {
  final DateTime endsAt;
  final VoidCallback onExpired;

  const VotingTimer({super.key, required this.endsAt, required this.onExpired});

  @override
  State<VotingTimer> createState() => _VotingTimerState();
}

class _VotingTimerState extends State<VotingTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _secondsTimer;
  int _secondsRemaining = 0;
  int _totalSeconds = 1;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    final remaining = widget.endsAt.difference(DateTime.now());
    _secondsRemaining = remaining.inSeconds.clamp(0, 86400);
    _totalSeconds = _secondsRemaining > 0 ? _secondsRemaining : 1;

    _controller = AnimationController(
      vsync: this,
      duration: _secondsRemaining > 0 ? remaining : Duration.zero,
      value: 1.0,
    );

    if (_secondsRemaining > 0) {
      _controller.reverse();
    } else {
      _handleExpiry();
    }

    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final secs = widget.endsAt.difference(DateTime.now()).inSeconds.clamp(0, 86400);
      setState(() => _secondsRemaining = secs);
      if (secs <= 0 && !_expired) _handleExpiry();
    });
  }

  void _handleExpiry() {
    _expired = true;
    _secondsTimer?.cancel();
    widget.onExpired();
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondsTimer?.cancel();
    super.dispose();
  }

  Color get _arcColor {
    final fraction = _secondsRemaining / _totalSeconds;
    if (fraction > 0.5) return Colors.green;
    if (fraction > 0.25) return Colors.amber.shade700;
    return Colors.red;
  }

  String get _timeLabel {
    if (_expired) return '0:00';
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _subLabel => _expired ? 'Confirming...' : 'remaining';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = _arcColor;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: _ArcPainter(
                        progress: _controller.value,
                        color: color,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _timeLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voting in Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.shade200
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
