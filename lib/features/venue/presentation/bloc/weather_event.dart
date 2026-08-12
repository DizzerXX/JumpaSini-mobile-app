part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeatherEvent extends WeatherEvent {
  final String shortCode;

  const LoadWeatherEvent(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}
