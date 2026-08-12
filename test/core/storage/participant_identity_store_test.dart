import 'package:flutter_test/flutter_test.dart';
import 'package:jumpa_sini/core/storage/participant_identity_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns null when nothing is stored for the session', () async {
    expect(await ParticipantIdentityStore.read('ABC123'), isNull);
  });

  test('round-trips a stored identity', () async {
    await ParticipantIdentityStore.save(
      'ABC123',
      const ParticipantIdentity(
        participantId: 'p-1',
        accessToken: 'tok-1',
        name: 'Danish',
      ),
    );

    final identity = await ParticipantIdentityStore.read('ABC123');

    expect(identity, isNotNull);
    expect(identity!.participantId, 'p-1');
    expect(identity.accessToken, 'tok-1');
    expect(identity.name, 'Danish');
  });

  test('keeps identities for different sessions separate', () async {
    await ParticipantIdentityStore.save(
      'AAA',
      const ParticipantIdentity(participantId: 'p-a', accessToken: 'tok-a'),
    );
    await ParticipantIdentityStore.save(
      'BBB',
      const ParticipantIdentity(participantId: 'p-b', accessToken: 'tok-b'),
    );

    expect((await ParticipantIdentityStore.read('AAA'))!.participantId, 'p-a');
    expect((await ParticipantIdentityStore.read('BBB'))!.participantId, 'p-b');
  });

  test('clear removes only the requested session', () async {
    await ParticipantIdentityStore.save(
      'AAA',
      const ParticipantIdentity(participantId: 'p-a', accessToken: 'tok-a'),
    );
    await ParticipantIdentityStore.save(
      'BBB',
      const ParticipantIdentity(participantId: 'p-b', accessToken: 'tok-b'),
    );

    await ParticipantIdentityStore.clear('AAA');

    expect(await ParticipantIdentityStore.read('AAA'), isNull);
    expect(await ParticipantIdentityStore.read('BBB'), isNotNull);
  });

  test('treats corrupted stored JSON as no identity', () async {
    SharedPreferences.setMockInitialValues({
      'participant_identity_ABC123': 'not-json',
    });

    expect(await ParticipantIdentityStore.read('ABC123'), isNull);
  });
}
