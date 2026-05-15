import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/venues_repository.dart';

part 'venues_event.dart';
part 'venues_state.dart';

class VenuesBloc extends Bloc<VenuesEvent, VenuesState> {
  final VenuesRepository _repository;

  VenuesBloc(this._repository) : super(const VenuesInitial()) {
    on<FetchVenuesRequested>(_onFetchVenues);
    on<VenuesReset>((_, emit) => emit(const VenuesInitial()));
  }

  Future<void> _onFetchVenues(
    FetchVenuesRequested event,
    Emitter<VenuesState> emit,
  ) async {
    emit(const VenuesLoading());
    try {
      final result = await _repository.fetchVenues(event.sessionCode);
      emit(VenuesLoaded(
        venues: (result['venues'] as List).cast<Map<String, dynamic>>(),
        midpoint: result['midpoint'] as Map<String, dynamic>,
      ));
    } catch (e) {
      emit(VenuesError(e.toString()));
    }
  }
}
