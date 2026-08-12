import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../../features/collaboration/data/datasources/collaboration_remote_datasource.dart';
import '../../features/collaboration/data/repositories/collaboration_repository_impl.dart';
import '../../features/collaboration/domain/repositories/collaboration_repository.dart';
import '../../features/collaboration/domain/usecases/cast_vote.dart';
import '../../features/collaboration/domain/usecases/confirm_venue.dart';
import '../../features/collaboration/domain/usecases/get_session_summary.dart';
import '../../features/collaboration/domain/usecases/get_votes.dart';
import '../../features/collaboration/domain/usecases/start_voting.dart';
import '../../features/collaboration/domain/usecases/trigger_midpoint.dart';
import '../../features/collaboration/presentation/bloc/collaboration_bloc.dart';
import '../../features/session/data/datasources/places_remote_datasource.dart';
import '../../features/session/data/datasources/session_remote_datasource.dart';
import '../../features/session/data/repositories/session_repository_impl.dart';
import '../../features/session/domain/repositories/session_repository.dart';
import '../../features/session/domain/usecases/add_participant.dart';
import '../../features/session/domain/usecases/calculate_midpoint.dart';
import '../../features/session/domain/usecases/create_session.dart';
import '../../features/session/domain/usecases/get_session.dart';
import '../../features/session/domain/usecases/remove_participant.dart';
import '../../features/session/presentation/bloc/session_bloc.dart';
import '../../features/venue/data/datasources/venue_remote_datasource.dart';
import '../../features/venue/data/repositories/venue_repository_impl.dart';
import '../../features/venue/domain/repositories/venue_repository.dart';
import '../../features/venue/domain/usecases/get_recommendation.dart';
import '../../features/venue/domain/usecases/get_venues.dart';
import '../../features/venue/presentation/bloc/venue_bloc.dart';
import '../../features/venue/presentation/bloc/weather_bloc.dart';

final sl = GetIt.instance;

void setup() {
  // Network
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  // ── Places (backend proxy) ───────────────────────────────────────────────
  sl.registerLazySingleton<PlacesRemoteDatasource>(
    () => PlacesRemoteDatasourceImpl(sl()),
  );

  // ── Session ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SessionRemoteDatasource>(
    () => SessionRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => CreateSession(sl()));
  sl.registerLazySingleton(() => AddParticipant(sl()));
  sl.registerLazySingleton(() => GetSession(sl()));
  sl.registerLazySingleton(() => RemoveParticipant(sl()));
  sl.registerLazySingleton(() => CalculateMidpoint(sl()));
  sl.registerFactory(
    () => SessionBloc(
      createSession: sl(),
      addParticipant: sl(),
      getSession: sl(),
      removeParticipant: sl(),
      calculateMidpoint: sl(),
    ),
  );

  // ── Collaboration ────────────────────────────────────────────────────────
  sl.registerLazySingleton<CollaborationRemoteDatasource>(
    () => CollaborationRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<CollaborationRepository>(
    () => CollaborationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => CastVote(sl()));
  sl.registerLazySingleton(() => GetVotes(sl()));
  sl.registerLazySingleton(() => ConfirmVenue(sl()));
  sl.registerLazySingleton(() => GetSessionSummary(sl()));
  sl.registerLazySingleton(() => StartVoting(sl()));
  sl.registerLazySingleton(() => TriggerMidpoint(sl()));
  sl.registerFactory(
    () => CollaborationBloc(
      castVote:          sl(),
      getVotes:          sl(),
      confirmVenue:      sl(),
      getSessionSummary: sl(),
      startVoting:       sl(),
      triggerMidpoint:   sl(),
    ),
  );

  // ── Venue ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<VenueRemoteDatasource>(
    () => VenueRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<VenueRepository>(
    () => VenueRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetVenues(sl()));
  sl.registerLazySingleton(() => GetRecommendation(sl()));
  sl.registerFactory(
    () => VenueBloc(
      getVenues: sl(),
      getRecommendation: sl(),
      venueRepository: sl(),
    ),
  );
  sl.registerFactory(() => WeatherBloc(venueRepository: sl()));
}
