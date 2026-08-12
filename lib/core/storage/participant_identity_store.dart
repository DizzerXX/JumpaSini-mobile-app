import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Which participant this device is, within a given session.
class ParticipantIdentity {
  final String participantId;
  final String accessToken;
  final String? name;

  const ParticipantIdentity({
    required this.participantId,
    required this.accessToken,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'participant_id': participantId,
        'access_token': accessToken,
        'name': name,
      };

  static ParticipantIdentity? fromJson(Map<String, dynamic> json) {
    final id = json['participant_id'] as String?;
    final token = json['access_token'] as String?;

    if (id == null || token == null) return null;

    return ParticipantIdentity(
      participantId: id,
      accessToken: token,
      name: json['name'] as String?,
    );
  }
}

/// Persists the per-participant access token the backend returns exactly once, in
/// the addParticipant response.
///
/// The session short code is shared with the whole group, so it proves nothing about
/// identity. This token is what lets the backend tell "this device is participant X"
/// apart from "someone who has the link" — required to vote and to leave a session.
class ParticipantIdentityStore {
  static const _prefix = 'participant_identity_';

  static Future<void> save(String shortCode, ParticipantIdentity identity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$shortCode', jsonEncode(identity.toJson()));
  }

  static Future<ParticipantIdentity?> read(String shortCode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$shortCode');

    if (raw == null) return null;

    try {
      return ParticipantIdentity.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on FormatException {
      return null;
    }
  }

  static Future<void> clear(String shortCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$shortCode');
  }
}
