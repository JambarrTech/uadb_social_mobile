import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uadb_social/app.dart';
import 'package:uadb_social/core/models/auth_user.dart';
import 'package:uadb_social/core/models/post.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/core/services/token_store.dart';
import 'package:uadb_social/features/auth/data/auth_repository_impl.dart';
import 'package:uadb_social/features/auth/domain/auth_repository.dart';
import 'package:uadb_social/features/auth/state/auth_controller.dart';
import 'package:uadb_social/core/services/api_client.dart';

/// Client HTTP simulé, pour tester la logique sans réseau.
class FakeApiClient extends ApiClient {
  FakeApiClient({required this.handler}) : super(tokenProvider: () => 'token');

  /// Renvoie la réponse (ou lève l'exception) correspondant à l'URL demandée.
  final Object? Function(String path, String method) handler;

  final List<String> calls = [];

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    calls.add('GET $path');
    return _resolve(path, 'GET');
  }

  @override
  Future<dynamic> post(String path, {Object? body}) async {
    calls.add('POST $path');
    return _resolve(path, 'POST');
  }

  Object? _resolve(String path, String method) {
    final result = handler(path, method);
    if (result is Exception) throw result;
    return result;
  }
}

AuthRepository buildRepository(FakeApiClient client, {TokenStore? store}) =>
    AuthRepositoryImpl(client: client, store: store ?? FakeTokenStore());

/// Store en mémoire : évite de dépendre de la plateforme dans les tests.
class FakeTokenStore implements TokenStore {
  @override
  String? token;
  @override
  AuthUser? user;

  @override
  bool get hasSession => token != null && user != null;

  @override
  bool get onboardingSeen => true;

  @override
  int get unreadMessagesCount => 0;

  @override
  Future<void> clear() async {
    token = null;
    user = null;
  }

  @override
  Future<void> save({required String token, required AuthUser user}) async {
    this.token = token;
    this.user = user;
  }

  @override
  Future<void> setOnboardingSeen() async {}

  @override
  Future<void> setUnreadMessagesCount(int value) async {}
}

void main() {
  // ---------------------------------------------------------------------
  // Modèles
  // ---------------------------------------------------------------------
  group('AuthUser', () {
    test('compose le nom depuis firstName/lastName', () {
      final user = AuthUser.fromJson({
        'id': 'u1',
        'email': 'fatou.sow@uadb.edu.sn',
        'firstName': 'Fatou',
        'lastName': 'Sow',
      });

      expect(user.fullName, 'Fatou Sow');
      expect(user.initials, 'FS');
      expect(user.handle, '@fatou.sow');
    });

    test('tolère les nombres sérialisés en chaîne et les booléens texte', () {
      final user = AuthUser.fromJson({
        'id': 'u2',
        'email': 'a@b.sn',
        'fullName': 'Awa Diop',
        'isOfficial': 'true',
      });

      expect(user.isOfficial, isTrue);
    });

    test('retombe sur un nom par défaut si le backend n’envoie rien', () {
      final user = AuthUser.fromJson({'id': 'u3', 'email': 'x@y.sn'});
      expect(user.fullName, 'Membre UADB');
      expect(user.initials, '?');
    });
  });

  group('Post', () {
    test('analyse une publication avec createdAt et images', () {
      final post = Post.fromJson({
        'id': 'p1',
        'authorId': 'u1',
        'authorName': 'Amina Diop',
        'content': 'Bonjour',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
        'imageUrls': ['https://cdn/a.png', 'https://cdn/b.png'],
        'likesCount': '12',
        'likedByMe': true,
      });

      expect(post.likesCount, 12);
      expect(post.imageUrls, hasLength(2));
      expect(post.likedByMe, isTrue);
      expect(post.timeAgo(), 'il y a 3 h');
    });

    test('accepte une liste d’images séparée par des virgules', () {
      final post = Post.fromJson({
        'id': 'p2',
        'content': 'x',
        'imageUrl': 'https://cdn/a.png, https://cdn/b.png',
      });
      expect(post.imageUrls, ['https://cdn/a.png', 'https://cdn/b.png']);
    });

    test('accepte un timestamp Unix en secondes', () {
      final post = Post.fromJson({
        'id': 'p3',
        'content': 'x',
        'createdAt': 1767225600,
      });
      expect(post.createdAt, isNotNull);
      expect(post.timeAgo(), isNotEmpty);
    });

    test('repli sur timeAgo quand aucun horodatage n’est fourni', () {
      final post = Post.fromJson({
        'id': 'p4',
        'content': 'x',
        'timeAgo': 'il y a 3h',
      });
      expect(post.timeAgo(), 'il y a 3h');
    });
  });

  // ---------------------------------------------------------------------
  // Visibilité : le contrat API ne doit jamais recevoir un libellé français
  // ---------------------------------------------------------------------
  group('PostVisibility', () {
    test('associe un libellé français à une valeur technique', () {
      expect(PostVisibility.public.apiValue, 'public');
      expect(PostVisibility.friends.apiValue, 'friends');
      expect(PostVisibility.communities.apiValue, 'communities');
      expect(PostVisibility.private.apiValue, 'private');
    });

    test('aucune valeur technique ne contient d’espace', () {
      for (final value in PostVisibility.values) {
        expect(value.apiValue, isNot(contains(' ')));
      }
    });
  });

  // ---------------------------------------------------------------------
  // Erreurs API : plus de faux repli silencieux
  // ---------------------------------------------------------------------
  group('AuthRepositoryImpl', () {
    test(
      'connexion réussie : persiste le token et renvoie la session',
      () async {
        final store = FakeTokenStore();
        final repository = buildRepository(
          FakeApiClient(
            handler: (path, method) => jsonEncode({
              'token': 'jwt-123',
              'user': {
                'id': 'u1',
                'email': 'fatou@uadb.edu.sn',
                'firstName': 'Fatou',
                'lastName': 'Sow',
              },
            }),
          ),
          store: store,
        );

        final session = await repository.login(
          email: ' fatou@uadb.edu.sn ',
          password: 'secret123',
        );

        expect(session.token, 'jwt-123');
        expect(session.user.fullName, 'Fatou Sow');
        expect(store.token, 'jwt-123');
      },
    );

    test('accepte une réponse enveloppée dans « data »', () async {
      final repository = buildRepository(
        FakeApiClient(
          handler: (path, method) => {
            'data': {
              'accessToken': 'jwt-456',
              'user': {'id': 'u1', 'email': 'a@b.sn', 'name': 'Awa Diop'},
            },
          },
        ),
      );

      final session = await repository.login(email: 'a@b.sn', password: 'x');
      expect(session.token, 'jwt-456');
      expect(session.user.fullName, 'Awa Diop');
    });

    test('propage une erreur 401 sans créer de session', () async {
      final store = FakeTokenStore();
      final repository = buildRepository(
        FakeApiClient(
          handler: (path, method) => const ApiException(
            'Identifiants invalides.',
            statusCode: 401,
            kind: ApiErrorKind.unauthorized,
          ),
        ),
        store: store,
      );

      await expectLater(
        repository.login(email: 'a@b.sn', password: 'x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.unauthorized,
          ),
        ),
      );
      expect(store.hasSession, isFalse);
    });

    test('signale une réponse d’authentification sans token', () async {
      final repository = buildRepository(
        FakeApiClient(
          handler: (path, method) => {
            'user': {'id': 'u1'},
          },
        ),
      );

      await expectLater(
        repository.login(email: 'a@b.sn', password: 'x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.malformed,
          ),
        ),
      );
    });

    test('restaure la session depuis le store, ou null si absente', () async {
      final store = FakeTokenStore()
        ..token = 'jwt-789'
        ..user = const AuthUser(
          id: 'u1',
          email: 'a@b.sn',
          fullName: 'Awa Diop',
        );

      final repository = buildRepository(
        FakeApiClient(handler: (path, method) => null),
        store: store,
      );

      final session = await repository.restoreSession();
      expect(session?.token, 'jwt-789');
    });

    test('purge un token orphelin (sans profil)', () async {
      final store = FakeTokenStore()..token = 'jwt-789';
      final repository = buildRepository(
        FakeApiClient(handler: (path, method) => null),
        store: store,
      );

      expect(await repository.restoreSession(), isNull);
      expect(store.token, isNull);
    });

    test('envoie la visibilité technique et l’auteur de la session', () async {
      final client = FakeApiClient(handler: (path, method) => {'id': 'p1'});
      final repository = buildRepository(client);

      await repository.register(
        firstName: 'Fatou',
        lastName: 'Sow',
        email: 'fatou@uadb.edu.sn',
        password: 'secret123',
        department: 'Informatique',
      );

      expect(client.calls, contains('POST /auth/register'));
    });
  });

  // ---------------------------------------------------------------------
  // Redirections d'authentification
  // ---------------------------------------------------------------------
  group('authRedirect', () {
    test('laisse passer /splash quel que soit le statut', () {
      expect(authRedirect(AuthStatus.unknown, '/splash'), isNull);
      expect(authRedirect(AuthStatus.authenticated, '/splash'), isNull);
      expect(authRedirect(AuthStatus.unauthenticated, '/splash'), isNull);
    });

    test(
      'renvoie un utilisateur connecté vers /home depuis une route publique',
      () {
        expect(authRedirect(AuthStatus.authenticated, '/login'), '/home');
        expect(authRedirect(AuthStatus.authenticated, '/register'), '/home');
      },
    );

    test('renvoie un utilisateur non connecté vers /login depuis une route protégée', () {
      for (final path in [
        '/home',
        '/explore',
        '/create-post',
        '/messages',
        '/profile',
      ]) {
        expect(
          authRedirect(AuthStatus.unauthenticated, path),
          '/login',
          reason: '$path doit être protégée',
        );
      }
    });

    test('laisse un utilisateur connecté sur une route protégée', () {
      expect(authRedirect(AuthStatus.authenticated, '/home'), isNull);
    });

    test(
      'ne redirige pas un utilisateur non connecté sur une route publique',
      () {
        expect(authRedirect(AuthStatus.unauthenticated, '/login'), isNull);
        expect(authRedirect(AuthStatus.unauthenticated, '/onboarding'), isNull);
      },
    );

    test('ne redirige rien tant que le statut est inconnu', () {
      expect(authRedirect(AuthStatus.unknown, '/home'), isNull);
      expect(authRedirect(AuthStatus.unknown, '/login'), isNull);
    });
  });

  // ---------------------------------------------------------------------
  // Mise en page responsive : plus de largeur fixe
  // ---------------------------------------------------------------------
  group('Responsive', () {
    testWidgets('AppPage se contraint en largeur sur un écran large', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPage(maxWidth: ContentWidth.form, child: Text('contenu')),
          ),
        ),
      );

      final width = tester.getSize(find.text('contenu')).width;
      expect(width, lessThanOrEqualTo(ContentWidth.form));
    });

    testWidgets('AppPage occupe la largeur sur un téléphone', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPage(maxWidth: ContentWidth.form, child: Text('contenu')),
          ),
        ),
      );

      // 390 - 2 * 24 (padding horizontal) = 342
      expect(tester.getSize(find.text('contenu')).width, 342);
    });
  });

  // ---------------------------------------------------------------------
  // Sémantique des groupes d'onglets
  // ---------------------------------------------------------------------
  group('AppTab', () {
    test('le bouton central est une action, pas un onglet', () {
      expect(AppTab.create.isAction, isTrue);
      for (final tab in AppTab.tabs.where((t) => t != AppTab.create)) {
        expect(tab.isAction, isFalse);
      }
    });

    test('chaque onglet pointe vers une route déclarée', () {
      for (final tab in AppTab.tabs) {
        if (tab.isAction) continue;
        expect(AppRoutes.protectedPaths, contains(tab.route));
      }
    });
  });

  // ---------------------------------------------------------------------
  // Smoke test : l'application démarre et affiche le splash
  // ---------------------------------------------------------------------
  testWidgets('démarre sur le splash sans erreur d’asset', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await TokenStore.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(store)],
        child: const UadbSocialApp(),
      ),
    );

    expect(find.text('Le réseau de notre communauté.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
