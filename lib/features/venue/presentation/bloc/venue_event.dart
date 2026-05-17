part of 'venue_bloc.dart';

abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object?> get props => [];
}

class LoadVenuesEvent extends VenueEvent {
  final String shortCode;

  const LoadVenuesEvent(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}

class FilterVenuesEvent extends VenueEvent {
  final bool? halalOnly;

  const FilterVenuesEvent(this.halalOnly);

  @override
  List<Object?> get props => [halalOnly];
}

class ReportHalalEvent extends VenueEvent {
  final String placeId;
  final bool isHalal;
  final String shortCode;
  final String? sessionId;

  const ReportHalalEvent({
    required this.placeId,
    required this.isHalal,
    required this.shortCode,
    this.sessionId,
  });

  @override
  List<Object?> get props => [placeId, isHalal, shortCode, sessionId];
}

class LoadRecommendationEvent extends VenueEvent {
  final String shortCode;

  const LoadRecommendationEvent(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}
