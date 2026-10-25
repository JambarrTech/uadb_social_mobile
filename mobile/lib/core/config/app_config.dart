/// Configuration de l'application, résolue à la compilation.
///
/// L'application fonctionne aujourd'hui **sans aucun appel réseau** : la couche
/// HTTP a été retirée tant qu'aucun serveur n'existe. Tous les drapeaux ci-dessous
/// pilotent le comportement de démonstration et peuvent être activés ou non via
/// `--dart-define`.
class AppConfig {
  const AppConfig._();

  /// Exiger une session avant d'accéder aux écrans.
  ///
  /// `true` (défaut) : le splash mène à la connexion et les routes privées
  /// redirigent vers `/login` tant qu'aucune session n'existe.
  ///
  /// ```sh
  /// flutter run --dart-define=REQUIRE_AUTH=false   # ouverture directe
  /// ```
  static const bool requireAuth = bool.fromEnvironment(
    'REQUIRE_AUTH',
    defaultValue: true,
  );

  /// Contourner la vérification des identifiants.
  ///
  /// `true` (défaut) : le formulaire de connexion accepte n'importe quelle
  /// adresse e-mail et n'importe quel mot de passe, et construit une session
  /// locale à partir de ce qui est saisi. La validation bloquante est désactivée.
  ///
  /// `false` : les comptes sont réellement enregistrés et vérifiés sur
  /// l'appareil (mot de passe salé-haché SHA-256, jamais en clair).
  ///
  /// ```sh
  /// flutter run --dart-define=AUTH_BYPASS=false
  /// ```
  static const bool authBypass = bool.fromEnvironment(
    'AUTH_BYPASS',
    defaultValue: true,
  );
}
