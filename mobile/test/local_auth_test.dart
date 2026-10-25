import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadb_social/core/config/app_config.dart';
import 'package:uadb_social/core/services/token_store.dart';
import 'package:uadb_social/features/auth/data/local_account_store.dart';
import 'package:uadb_social/features/auth/data/local_auth_repository.dart';
import 'package:uadb_social/features/auth/state/auth_controller.dart';

void main() {
  late TokenStore store;
  late LocalAccountStore accounts;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await TokenStore.create();
    accounts = LocalAccountStore(store.preferences);
  });

  /// Dépôt en mode contournement : c'est le comportement par défaut.
  LocalAuthRepository demoMode() =>
      LocalAuthRepository(store: store, accounts: accounts);

  /// Dépôt en mode strict (AUTH_BYPASS=false).
  LocalAuthRepository strictMode() => LocalAuthRepository(
    store: store,
    accounts: accounts,
  );

  group('mode démonstration (défaut)', () {
    test('accepte une adresse et un mot de passe arbitraires', () async {
      // Le dépôt lit AppConfig.authBypass, forcé à `true` par défaut.
      expect(AppConfig.authBypass, isTrue);

      final session = await demoMode().login(
        email: 'ceci nest pas un email',
        password: 'xyz',
      );

      expect(session.token, isNotEmpty);
      expect(store.hasSession, isTrue);
    });

    test('accepte des champs totalement vides', () async {
      final session = await demoMode().login(email: '', password: '');

      expect(session.token, isNotEmpty);
    });

    test('déduit un nom lisible depuis l’adresse saisie', () async {
      final session = await demoMode().login(
        email: 'fatou.sow@uadb.edu.sn',
        password: 'x',
      );

      expect(session.user.fullName, 'Fatou Sow');
      expect(session.user.email, 'fatou.sow@uadb.edu.sn');
    });

    test('tolère une adresse sans séparateur', () async {
      final session = await demoMode().login(email: 'zzzz', password: 'x');
      expect(session.user.fullName, isNotEmpty);
    });

    test('n’écrit aucun compte dans le registre', () async {
      await demoMode().register(
        firstName: 'Fatou',
        lastName: 'Sow',
        email: 'fatou@uadb.edu.sn',
        password: 'secret123',
        department: 'Informatique',
      );

      expect(accounts.findByEmail('fatou@uadb.edu.sn'), isNull);
    });

    test('inscription puis connexion avec des valeurs arbitraires', () async {
      await demoMode().register(
        firstName: 'Awa',
        lastName: 'Ndiaye',
        email: 'awa@uadb.edu.sn',
        password: 'peu importe',
        department: 'Droit',
      );
      await demoMode().logout();

      // En mode démonstration, rien n'est enregistré : la connexion reconstruit
      // un profil à partir de l'adresse saisie, quel que soit le mot de passe.
      final session = await demoMode().login(
        email: 'awa@uadb.edu.sn',
        password: 'un autre mot de passe',
      );

      expect(session.user.fullName, 'Awa');
      expect(session.user.email, 'awa@uadb.edu.sn');
    });
  });

  group('hachage (mode strict)', () {
    test('dépend du sel', () {
      expect(
        LocalAccount.hashPassword('secret123', 'user-1'),
        isNot(LocalAccount.hashPassword('secret123', 'user-2')),
      );
    });

    test('est déterministe', () {
      expect(
        LocalAccount.hashPassword('secret123', 'user-1'),
        LocalAccount.hashPassword('secret123', 'user-1'),
      );
    });

    test('ne stocke jamais le mot de passe en clair', () async {
      // On écrit manuellement un compte, comme le ferait le mode strict.
      final user = (await strictMode().register(
        firstName: 'Fatou',
        lastName: 'Sow',
        email: 'fatou@uadb.edu.sn',
        password: 'secret123',
        department: 'Informatique',
      )).user;

      await accounts.save(
        LocalAccount(
          user: user,
          passwordHash: LocalAccount.hashPassword('secret123', user.id),
        ),
      );

      final raw = store.preferences.getString(LocalAccountStore.storageKey);
      expect(raw, isNotNull);
      expect(raw, isNot(contains('secret123')));
    });
  });

  group('session', () {
    test('reste restaurable après écriture', () async {
      await demoMode().login(email: 'a@b.sn', password: 'x');

      final session = await demoMode().restoreSession();

      expect(session, isNotNull);
      expect(session!.token, store.token);
    });

    test('la déconnexion efface la session', () async {
      await demoMode().login(email: 'a@b.sn', password: 'x');

      await demoMode().logout();

      expect(store.hasSession, isFalse);
      expect(await demoMode().restoreSession(), isNull);
    });
  });

  group('messages d’erreur', () {
    test('AuthFailure est reformulée telle quelle', () {
      expect(
        AuthState.describe(const AuthFailure('Adresse e-mail invalide.')),
        'Adresse e-mail invalide.',
      );
    });

    test('une erreur inconnue reste générique', () {
      expect(
        AuthState.describe(Exception('trace interne avec des détails')),
        'Une erreur inattendue est survenue.',
      );
    });
  });

  group('configuration', () {
    test('le contournement est actif par défaut', () {
      expect(AppConfig.authBypass, isTrue);
    });

    test('une session est exigée par défaut', () {
      expect(AppConfig.requireAuth, isTrue);
    });
  });
}
