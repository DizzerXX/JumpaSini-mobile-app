part of 'venues_bloc.dart';

abstract class VenuesEvent extends Equatable {
  const VenuesEvent();

  @override
  List<Object?> get props => [];
}

class FetchVenuesRequested extends VenuesEvent {
  final String sessionCode;

  const FetchVenuesRequested({required this.sessionCode});

  @override
  List<Object?> get props => [sessionCode];
}

class VenuesReset extends VenuesEvent {
  const VenuesReset();
}
