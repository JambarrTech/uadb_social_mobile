import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadb_social/core/models/auth_user.dart';

/// Un compte enregistré localement par le mode hors-ligne.
///
/// Le mot de passe n'est **jamais** stocké en clair : seul un SHA-256 salé est
/// conservé. Ce n'est pas un schéma de production — un serveur réel doit utiliser
/// Argon2 ou bcrypt — mais cela évite d'écrire des mots de passe en clair dans
/// les préférences de l'appareil.
class LocalAccount {
  const LocalAccount({
    required this.user,
    required this.passwordHash,
  });

  final AuthUser user;
  final String passwordHash;

  /// Vérifie un mot de passe face au hash salé stocké.
  bool matchesPassword(String password) =>
      hashPassword(password, user.id) == passwordHash;

  /// Dérive le hash salé. Le sel est l'identifiant du compte : il empêche que
  /// deux comptes de même mot de passe partagent le même hash, tout en restant
  /// déterministe pour pouvoir vérifier plus tard.
  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt::$password')).toString();

  Map<String, dynamic> toJson() => {
    ...user.toJson(),
    'passwordHash': passwordHash,
  };

  factory LocalAccount.fromJson(Map<String, dynamic> json) => LocalAccount(
    user: AuthUser.fromJson(json),
    passwordHash: json['passwordHash']?.toString() ?? '',
  );
}

/// Registre des comptes du mode hors-ligne.
class LocalAccountStore {
  LocalAccountStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'auth.accounts';

  List<LocalAccount> _readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<Object?>)
          .whereType<Map<String, dynamic>>()
          .map(LocalAccount.fromJson)
          .toList();
    } on FormatException {
      // Registre corrompu : on repart d'un état vide plutôt que de planter.
      return [];
    }
  }

  Future<void> _writeAll(List<LocalAccount> accounts) => _prefs.setString(
    storageKey,
    jsonEncode(accounts.map((account) => account.toJson()).toList()),
  );

  LocalAccount? findByEmail(String email) {
    final needle = email.trim().toLowerCase();
    for (final account in _readAll()) {
      if (account.user.email.toLowerCase() == needle) return account;
    }
    return null;
  }

  bool emailTaken(String email) => findByEmail(email) != null;

  Future<void> save(LocalAccount account) async {
    final accounts = _readAll()
        .where((existing) => existing.user.id != account.user.id)
        .toList()
      ..add(account);
    await _writeAll(accounts);
  }

  Future<void> clear() => _prefs.remove(storageKey);
}
