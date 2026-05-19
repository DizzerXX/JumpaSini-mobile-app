import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recommendation_entity.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/weather_assessment.dart';
import '../../domain/usecases/get_recommendation.dart';
import '../../domain/usecases/get_venues.dart';
import '../../domain/repositories/venue_repository.dart';

part 'venue_event.dart';
part 'venue_state.dart';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  final GetVenues _getVenues;
  final GetRecommendation _getRecommendation;
  final VenueRepository _venueRepository;

  VenueBloc({
    required GetVenues getVenues,
    required GetRecommendation getRecommendation,
    required VenueRepository venueRepository,
  })  : _getVenues = getVenues,
        _getRecommendation = getRecommendation,
        _venueRepository = venueRepository,
        super(const VenueInitial()) {
    on<LoadVenuesEvent>(_onLoadVenues);
    on<FilterVenuesEvent>(_onFilterVenues);
    on<ReportHalalEvent>(_onReportHalal);
    on<LoadRecommendationEvent>(_onLoadRecommendation);
    on<LoadWeatherEvent>(_onLoadWeather);
  }

  Future<void> _onLoadVenues(
    LoadVenuesEvent event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    final result = await _getVenues(event.shortCode);
    result.fold(
      (failure) => emit(VenueError(failure.message)),
      (venues) => emit(VenuesLoaded(venues: venues, filteredVenues: venues)),
    );
  }

  void _onFilterVenues(FilterVenuesEvent event, Emitter<VenueState> emit) {
    final current = state;
    if (current is! VenuesLoaded) return;

    final filtered = event.halalOnly == true
        ? current.venues.where((v) => v.isHalal == true).toList()
        : current.venues;

    emit(VenuesLoaded(venues: current.venues, filteredVenues: filtered));
  }

  Future<void> _onReportHalal(
    ReportHalalEvent event,
    Emitter<VenueState> emit,
  ) async {
    final result = await _venueRepository.reportHalal(
      event.placeId,
      event.isHalal,
      event.sessionId,
    );
    result.fold(
      (failure) => emit(VenueError(failure.message)),
      (_) {
        emit(const HalalReportSubmitted());
        add(LoadVenuesEvent(event.shortCode));
      },
    );
  }

  Future<void> _onLoadRecommendation(
    LoadRecommendationEvent event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    final result = await _getRecommendation(event.shortCode);
    result.fold(
      (failure) => emit(VenueError(failure.message)),
      (recommendation) => emit(RecommendationLoaded(recommendation)),
    );
  }

  Future<void> _onLoadWeather(
    LoadWeatherEvent event,
    Emitter<VenueState> emit,
  ) async {
    final result = await _venueRepository.getWeather(event.shortCode);
    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (assessment) => emit(WeatherLoaded(assessment)),
    );
  }
}
