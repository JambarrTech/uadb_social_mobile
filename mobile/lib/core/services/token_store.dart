import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

/// Persistance locale de la session (token + profil minimal).
///
/// Le token n'est jamais écrit en clair dans le code : il provient de la
/// réponse du backend et vit uniquement dans le stockage local de l'app.
class TokenStore {
  TokenStore(this._prefs);

  final SharedPreferences _prefs;

  /// Accès aux préférences sous-jacentes.
  ///
  /// Exposé pour que [LocalAccountStore] puisse partager le même stockage, sans
  /// créer une seconde instance de `SharedPreferences`.
  SharedPreferences get preferences => _prefs;

  static const String _tokenKey = 'auth.token';
  static const String _userKey = 'auth.user';

  /// Clé indiquant que l'onboarding a déjà été vu.
  static const String onboardingSeenKey = 'onboarding.seen';

  /// Clé du compteur de messages non lus (badge de la barre de navigation).
  static const String unreadMessagesKey = 'messages.unread';

  /// Crée un store en chargeant `SharedPreferences` une seule fois.
  static Future<TokenStore> create() async =>
      TokenStore(await SharedPreferences.getInstance());


  String? get token => _prefs.getString(_tokenKey);

  AuthUser? get user {
    final raw = _prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      // Donnée corrompue : on la purge plutôt que de planter au démarrage.
      _prefs.remove(_userKey);
      return null;
    }
  }

  bool get hasSession => (token?.isNotEmpty ?? false) && user != null;

  bool get onboardingSeen => _prefs.getBool(onboardingSeenKey) ?? false;

  int get unreadMessagesCount => _prefs.getInt(unreadMessagesKey) ?? 0;

  Future<void> save({required String token, required AuthUser user}) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(onboardingSeenKey, true);

  Future<void> setUnreadMessagesCount(int value) =>
      _prefs.setInt(unreadMessagesKey, value);

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    // Le badge de messages et l'onboarding ne dépendent pas de la session :
    // on ne les remet pas à zéro ici.
  }
}
