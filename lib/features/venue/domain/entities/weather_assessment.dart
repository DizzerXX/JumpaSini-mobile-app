import 'package:equatable/equatable.dart';

import 'forecast_entry.dart';

class WeatherAssessment extends Equatable {
  final String severity;
  final String headline;
  final String message;
  final String emoji;
  final bool shouldWarn;
  final bool isSafe;
  final double temperature;
  final int humidity;
  final List<ForecastEntry> forecast;

  const WeatherAssessment({
    required this.severity,
    required this.headline,
    required this.message,
    required this.emoji,
    required this.shouldWarn,
    required this.isSafe,
    required this.temperature,
    required this.humidity,
    required this.forecast,
  });

  @override
  List<Object?> get props => [
        severity,
        headline,
        message,
        emoji,
        shouldWarn,
        isSafe,
        temperature,
        humidity,
        forecast,
      ];
}
