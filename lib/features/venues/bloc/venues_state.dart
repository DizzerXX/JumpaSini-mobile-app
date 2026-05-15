part of 'venues_bloc.dart';

abstract class VenuesState extends Equatable {
  const VenuesState();

  @override
  List<Object?> get props => [];
}

class VenuesInitial extends VenuesState {
  const VenuesInitial();
}

class VenuesLoading extends VenuesState {
  const VenuesLoading();
}

class VenuesLoaded extends VenuesState {
  final List<Map<String, dynamic>> venues;
  final Map<String, dynamic> midpoint;

  const VenuesLoaded({required this.venues, required this.midpoint});

  @override
  List<Object?> get props => [venues, midpoint];
}

class VenuesError extends VenuesState {
  final String message;

  const VenuesError(this.message);

  @override
  List<Object?> get props => [message];
}
