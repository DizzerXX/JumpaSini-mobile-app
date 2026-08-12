import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weather_assessment.dart';
import '../../domain/repositories/venue_repository.dart';

part 'weather_event.dart';
part 'weather_state.dart';

/// Weather owns its own bloc rather than sharing VenueBloc's state slot.
///
/// Previously `WeatherLoaded` was emitted into `VenueState`, which *replaced* the
/// `VenuesLoaded` state and wiped the venue list — screens only survived by keeping
/// a shadow copy of the venues in widget state. Separate blocs mean the two can
/// load independently and neither can clobber the other.
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final VenueRepository _venueRepository;

  WeatherBloc({required VenueRepository venueRepository})
      : _venueRepository = venueRepository,
        super(const WeatherInitial()) {
    on<LoadWeatherEvent>(_onLoadWeather);
  }

  Future<void> _onLoadWeather(
    LoadWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    final result = await _venueRepository.getWeather(event.shortCode);

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (assessment) => emit(WeatherLoaded(assessment)),
    );
  }
}
