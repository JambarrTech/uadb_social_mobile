import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stockage local des publications enregistrées (« favoris »).
///
/// Sans backend, l'enregistrement d'une publication est un choix local :
/// l'identifiant est conservé sur l'appareil et la publication reste
/// marquée après une relance. Aucune commande serveur n'est fabriquée.
class LocalSavedStore {
  LocalSavedStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'posts.saved_ids';

  Set<String> readSaved() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      return {for (final id in jsonDecode(raw) as List<Object?>) id.toString()};
    } on FormatException {
      // Stockage corrompu : on repart d'un ensemble vide plutôt que de
      // faire échouer le démarrage du fil.
      return <String>{};
    }
  }

  Future<void> writeSaved(Set<String> ids) =>
      _prefs.setString(storageKey, jsonEncode(ids.toList()));
}
