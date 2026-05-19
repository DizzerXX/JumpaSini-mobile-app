import '../../domain/entities/forecast_entry.dart';
import '../../domain/entities/weather_assessment.dart';

class WeatherModel extends WeatherAssessment {
  const WeatherModel({
    required super.severity,
    required super.headline,
    required super.message,
    required super.emoji,
    required super.shouldWarn,
    required super.isSafe,
    required super.temperature,
    required super.humidity,
    required super.forecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final assessment = json['assessment'] as Map<String, dynamic>? ?? json;

    final rawForecast = json['forecast'] as List<dynamic>? ?? [];
    final forecast = rawForecast
        .map((e) => _parseForecastEntry(e as Map<String, dynamic>))
        .toList();

    return WeatherModel(
      severity:    assessment['severity'] as String? ?? 'good',
      headline:    assessment['headline'] as String? ?? '',
      message:     assessment['message']  as String? ?? '',
      emoji:       assessment['emoji']    as String? ?? '☀️',
      shouldWarn:  assessment['should_warn'] as bool? ?? false,
      isSafe:      assessment['is_safe']     as bool? ?? true,
      temperature: (assessment['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity:    (assessment['humidity']    as num?)?.toInt()    ?? 0,
      forecast:    forecast,
    );
  }

  static ForecastEntry _parseForecastEntry(Map<String, dynamic> e) {
    return ForecastEntry(
      time:        e['time']        as String? ?? '',
      condition:   e['condition']   as String? ?? '',
      temperature: (e['temperature'] as num?)?.toDouble() ?? 0.0,
      emoji:       e['emoji']       as String? ?? '☀️',
    );
  }
}
