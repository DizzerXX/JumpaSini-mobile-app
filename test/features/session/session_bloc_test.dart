import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumpa_sini/core/errors/failures.dart';
import 'package:jumpa_sini/features/session/domain/entities/session_entity.dart';
import 'package:jumpa_sini/features/session/domain/usecases/add_participant.dart';
import 'package:jumpa_sini/features/session/domain/usecases/calculate_midpoint.dart';
import 'package:jumpa_sini/features/session/domain/usecases/create_session.dart';
import 'package:jumpa_sini/features/session/domain/usecases/get_session.dart';
import 'package:jumpa_sini/features/session/domain/usecases/remove_participant.dart';
import 'package:jumpa_sini/features/session/presentation/bloc/session_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateSession extends Mock implements CreateSession {}

class MockAddParticipant extends Mock implements AddParticipant {}

class MockGetSession extends Mock implements GetSession {}

class MockRemoveParticipant extends Mock implements RemoveParticipant {}

class MockCalculateMidpoint extends Mock implements CalculateMidpoint {}

void main() {
  late MockCreateSession createSession;
  late MockAddParticipant addParticipant;
  late MockGetSession getSession;
  late MockRemoveParticipant removeParticipant;
  late MockCalculateMidpoint calculateMidpoint;

  // Not const: expiresAt is a DateTime.
  final session = SessionEntity(
    id: 's-1',
    shortCode: 'ABC123',
    transportMode: 'car',
    venueType: 'cafe',
    halalFilter: true,
    status: 'active',
    expiresAt: DateTime.utc(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const CreateSessionParams(
        transportMode: 'car',
        venueType: 'cafe',
        halalFilter: true,
      ),
    );
    registerFallbackValue(
      const AddParticipantParams(
        shortCode: 'ABC123',
        address: 'KLCC',
        latitude: 3.1,
        longitude: 101.7,
      ),
    );
    registerFallbackValue(
      const RemoveParticipantParams(shortCode: 'ABC123', participantId: 'p-1'),
    );
  });

  setUp(() {
    createSession = MockCreateSession();
    addParticipant = MockAddParticipant();
    getSession = MockGetSession();
    removeParticipant = MockRemoveParticipant();
    calculateMidpoint = MockCalculateMidpoint();
  });

  SessionBloc build() => SessionBloc(
        createSession: createSession,
        addParticipant: addParticipant,
        getSession: getSession,
        removeParticipant: removeParticipant,
        calculateMidpoint: calculateMidpoint,
      );

  group('GetSessionEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [Loading, Loaded] when the session is found',
      setUp: () => when(() => getSession.call(any()))
          .thenAnswer((_) async => Right(session)),
      build: build,
      act: (bloc) => bloc.add(const GetSessionEvent('ABC123')),
      expect: () => [
        const SessionLoading(),
        SessionLoaded(session),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'emits a friendly message when the session is missing',
      setUp: () => when(() => getSession.call(any()))
          .thenAnswer((_) async => const Left(NotFoundFailure('nope'))),
      build: build,
      act: (bloc) => bloc.add(const GetSessionEvent('ABC123')),
      expect: () => [
        const SessionLoading(),
        const SessionError(
          'Session not found. Check the code and try again.',
        ),
      ],
    );
  });

  group('AddParticipantEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits [Loading, ParticipantAdded] on success',
      setUp: () => when(() => addParticipant.call(any()))
          .thenAnswer((_) async => Right(session)),
      build: build,
      act: (bloc) => bloc.add(
        const AddParticipantEvent(
          shortCode: 'ABC123',
          address: 'KLCC, Kuala Lumpur',
          latitude: 3.1569,
          longitude: 101.7123,
        ),
      ),
      expect: () => [
        const SessionLoading(),
        ParticipantAdded(session),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'preserves field errors from a validation failure',
      setUp: () => when(() => addParticipant.call(any())).thenAnswer(
        (_) async => const Left(
          ValidationFailure(
            'Validation failed.',
            errors: {
              'location': ['Outside the supported area.'],
            },
          ),
        ),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const AddParticipantEvent(
          shortCode: 'ABC123',
          address: 'Kota Bharu',
          latitude: 6.12,
          longitude: 102.23,
        ),
      ),
      expect: () => [
        const SessionLoading(),
        const SessionError(
          'Validation failed.',
          errors: {
            'location': ['Outside the supported area.'],
          },
        ),
      ],
    );
  });

  group('CalculateMidpointEvent', () {
    blocTest<SessionBloc, SessionState>(
      'emits the calculated midpoint',
      setUp: () => when(() => calculateMidpoint.call(any())).thenAnswer(
        (_) async => const Right((lat: 3.15, lng: 101.71, isFair: true)),
      ),
      build: build,
      act: (bloc) => bloc.add(const CalculateMidpointEvent('ABC123')),
      expect: () => [
        const SessionLoading(),
        const MidpointCalculated(
          shortCode: 'ABC123',
          lat: 3.15,
          lng: 101.71,
          isFair: true,
        ),
      ],
    );

    blocTest<SessionBloc, SessionState>(
      'reports a network failure in plain language',
      setUp: () => when(() => calculateMidpoint.call(any()))
          .thenAnswer((_) async => const Left(NetworkFailure('offline'))),
      build: build,
      act: (bloc) => bloc.add(const CalculateMidpointEvent('ABC123')),
      expect: () => [
        const SessionLoading(),
        const SessionError('No internet connection. Please try again.'),
      ],
    );
  });
}
