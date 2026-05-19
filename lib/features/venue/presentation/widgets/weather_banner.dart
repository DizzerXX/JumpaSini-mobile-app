import 'package:flutter/material.dart';

import '../../domain/entities/weather_assessment.dart';
import '../../domain/entities/forecast_entry.dart';

class WeatherBanner extends StatelessWidget {
  final WeatherAssessment assessment;

  const WeatherBanner({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    if (assessment.severity == 'good') return const SizedBox.shrink();

    final colors = _colorsForSeverity(assessment.severity);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(assessment.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  assessment.headline,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            assessment.message,
            style: TextStyle(fontSize: 13, color: colors.text),
          ),
          if (assessment.forecast.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ForecastStrip(entries: assessment.forecast),
          ],
          if (assessment.severity == 'severe') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _popToSetup(context),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Choose indoor instead'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.border),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _popToSetup(BuildContext context) {
    // Pop back to SetupPage by removing all routes until the first named route
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  _BannerColors _colorsForSeverity(String severity) {
    return switch (severity) {
      'severe'  => const _BannerColors(
          background: Color(0xFFFEE2E2),
          border:     Color(0xFFF87171),
          text:       Color(0xFF991B1B),
        ),
      'warning' => const _BannerColors(
          background: Color(0xFFFFF7ED),
          border:     Color(0xFFFB923C),
          text:       Color(0xFF9A3412),
        ),
      _         => const _BannerColors(
          background: Color(0xFFFFFBEB),
          border:     Color(0xFFFBBF24),
          text:       Color(0xFF92400E),
        ),
    };
  }
}

class _ForecastStrip extends StatelessWidget {
  final List<ForecastEntry> entries;

  const _ForecastStrip({required this.entries});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: entries
            .map((e) => _ForecastChip(entry: e))
            .toList(),
      ),
    );
  }
}

class _ForecastChip extends StatelessWidget {
  final ForecastEntry entry;

  const _ForecastChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final hour = entry.time.length >= 16 ? entry.time.substring(11, 16) : entry.time;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(hour, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(entry.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            '${entry.temperature.round()}°',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BannerColors {
  final Color background;
  final Color border;
  final Color text;

  const _BannerColors({
    required this.background,
    required this.border,
    required this.text,
  });
}
