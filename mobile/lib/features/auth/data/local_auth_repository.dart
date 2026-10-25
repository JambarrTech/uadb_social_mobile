import 'dart:convert';
import 'dart:math';

import 'package:uadb_social/core/config/app_config.dart';
import 'package:uadb_social/core/models/auth_user.dart';
import 'package:uadb_social/core/services/token_store.dart';
import '../domain/auth_repository.dart';
import 'local_account_store.dart';

/// Authentification **sans serveur**.
///
/// Tant que le backend n'existe pas, l'application fonctionne en démonstration :
/// le formulaire de connexion accepte n'importe quelle adresse e-mail et
/// n'importe quel mot de passe, et une session locale est construite à partir
/// de ce qui est saisi.
///
/// En passant `AUTH_BYPASS=false`, on revient à un comportement strict : les
/// comptes sont enregistrés sur l'appareil, le mot de passe est salé-haché, et
/// les identifiants erronés sont refusés.
class LocalAuthRepository implements AuthRepository {
  const LocalAuthRepository({required this.store, required this.accounts});

  final TokenStore store;
  final LocalAccountStore accounts;

  /// Active la vérification des identifiants.
  bool get strict => !AppConfig.authBypass;

  static const String _emailTaken =
      'Un compte existe déjà avec cette adresse e-mail.';

  /// Message volontairement identique pour « compte inconnu » et « mot de
  /// passe faux » : ne pas révéler quelles adresses sont enregistrées.
  static const String _badCredentials =
      'Adresse e-mail ou mot de passe incorrect.';

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (!strict) {
      // Mode démonstration : n'importe quelle paire email / mot de passe
      // ouvre une session. Le nom est déduit de l'adresse pour que
      // l'interface affiche quelque chose de cohérent.
      return _openSession(
        AuthUser(
          id: _generateId(),
          email: email.trim(),
          fullName: _displayNameFromEmail(email),
        ),
      );
    }

    final account = accounts.findByEmail(email);
    if (account == null || !account.matchesPassword(password)) {
      throw const AuthFailure(_badCredentials);
    }
    return _openSession(account.user);
  }

  @override
  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String department,
  }) async {
    final normalizedEmail = email.trim();
    final composed = '${firstName.trim()} ${lastName.trim()}'.trim();
    final user = AuthUser(
      id: _generateId(),
      email: normalizedEmail,
      fullName: composed.isEmpty ? _displayNameFromEmail(email) : composed,
      department: department.trim().isEmpty ? null : department.trim(),
    );

    if (!strict) {
      // Mode démonstration : pas de registre, la session s'ouvre directement.
      return _openSession(user);
    }

    if (accounts.emailTaken(normalizedEmail)) {
      throw const AuthFailure(_emailTaken);
    }

    await accounts.save(
      LocalAccount(
        user: user,
        passwordHash: LocalAccount.hashPassword(password, user.id),
      ),
    );
    return _openSession(user);
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    // Sans serveur, aucun email ne part. Le rétablissement par lien est
    // impossible tant que le backend n'existe pas : l'écran de confirmation
    // reste affichable, mais rien n'est envoyé. À brancher plus tard.
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = store.token;
    if (token == null || token.isEmpty) return null;
    final user = store.user;
    if (user == null) {
      await store.clear();
      return null;
    }
    return AuthSession(token: token, user: user);
  }

  @override
  Future<void> logout() => store.clear();

  Future<AuthSession> _openSession(AuthUser user) async {
    final token = _generateToken();
    await store.save(token: token, user: user);
    return AuthSession(token: token, user: user);
  }

  /// Jeton opaque local. Il n'est jamais transmis sur le réseau : il sert
  /// uniquement à marquer la session comme ouverte dans l'appareil.
  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(8, (_) => random.nextInt(256));
    return 'u-${base64Url.encode(bytes).replaceAll('=', '')}';
  }

  /// Déduit un nom lisible depuis l'adresse saisie, pour que l'interface
  /// n'affiche pas une chaîne vide.
  static String _displayNameFromEmail(String email) {
    final local = email.trim().split('@').first;
    final words = local
        .split(RegExp(r'[._\-+]+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'Membre UADB';
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Erreur d'authentification déjà formulée pour l'utilisateur.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
