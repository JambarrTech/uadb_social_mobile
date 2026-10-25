import '../../../core/models/auth_user.dart';

/// Session authentifiée : token d'accès + profil associé.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;
}

/// Contrat d'authentification.
///
/// L'application n'appelle aucun serveur : l'implémentation active est locale
/// (voir `LocalAuthRepository`). Les implémentations propagent leurs erreurs
/// telles quelles : la couche UI décide du message affiché.
abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String department,
  });

  /// Demande un lien de réinitialisation. Ne révèle pas si l'adresse existe.
  Future<void> requestPasswordReset({required String email});

  /// Restaure la session depuis le stockage local, ou `null` si absente.
  Future<AuthSession?> restoreSession();

  Future<void> logout();
}
