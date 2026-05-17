part of 'venue_bloc.dart';

abstract class VenueState extends Equatable {
  const VenueState();

  @override
  List<Object?> get props => [];
}

class VenueInitial extends VenueState {
  const VenueInitial();
}

class VenueLoading extends VenueState {
  const VenueLoading();
}

class VenuesLoaded extends VenueState {
  final List<VenueEntity> venues;
  final List<VenueEntity> filteredVenues;

  const VenuesLoaded({required this.venues, required this.filteredVenues});

  @override
  List<Object?> get props => [venues, filteredVenues];
}

class RecommendationLoaded extends VenueState {
  final RecommendationEntity recommendation;

  const RecommendationLoaded(this.recommendation);

  @override
  List<Object?> get props => [recommendation];
}

class VenueError extends VenueState {
  final String message;

  const VenueError(this.message);

  @override
  List<Object?> get props => [message];
}

class HalalReportSubmitted extends VenueState {
  const HalalReportSubmitted();
}
