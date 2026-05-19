import 'package:equatable/equatable.dart';

class ForecastEntry extends Equatable {
  final String time;
  final String condition;
  final double temperature;
  final String emoji;

  const ForecastEntry({
    required this.time,
    required this.condition,
    required this.temperature,
    required this.emoji,
  });

  @override
  List<Object?> get props => [time, condition, temperature, emoji];
}
