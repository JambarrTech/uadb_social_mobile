import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uadb_social/app.dart';
import 'package:uadb_social/core/models/auth_user.dart';
import 'package:uadb_social/core/models/post.dart';
import 'package:uadb_social/core/navigation/app_nav.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/core/router/app_router.dart';
import 'package:uadb_social/core/services/token_store.dart';
import 'package:uadb_social/features/auth/state/auth_controller.dart';
import 'package:uadb_social/shared/widgets/responsive.dart';

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

    test('tolère les booléens texte', () {
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
      // Les initiales dérivent du nom de repli : « Membre UADB » → « MU »,
      // plus parlant qu'un point d'interrogation dans l'avatar.
      expect(user.initials, 'MU');
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
  // Redirections d'authentification
  // ---------------------------------------------------------------------
  group('authRedirect', () {
    test('sans garde : l’application est ouverte, rien n’est redirigé', () {
      for (final path in AppRoutes.publicPaths.union(
        AppRoutes.protectedPaths,
      )) {
        expect(
          authRedirect(AuthStatus.unauthenticated, path, requireAuth: false),
          isNull,
          reason: '$path doit rester accessible sans garde',
        );
      }
    });

    test('laisse passer /splash quel que soit le statut', () {
      expect(
        authRedirect(AuthStatus.unknown, '/splash', requireAuth: true),
        isNull,
      );
      expect(
        authRedirect(AuthStatus.authenticated, '/splash', requireAuth: true),
        isNull,
      );
      expect(
        authRedirect(AuthStatus.unauthenticated, '/splash', requireAuth: true),
        isNull,
      );
    });

    test(
      'renvoie un utilisateur connecté vers /home depuis une route publique',
      () {
        expect(
          authRedirect(AuthStatus.authenticated, '/login', requireAuth: true),
          '/home',
        );
        expect(
          authRedirect(
            AuthStatus.authenticated,
            '/register',
            requireAuth: true,
          ),
          '/home',
        );
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
          authRedirect(AuthStatus.unauthenticated, path, requireAuth: true),
          '/login',
          reason: '$path doit être protégée',
        );
      }
    });

    test('laisse un utilisateur connecté sur une route protégée', () {
      expect(
        authRedirect(AuthStatus.authenticated, '/home', requireAuth: true),
        isNull,
      );
    });

    test(
      'ne redirige pas un utilisateur non connecté sur une route publique',
      () {
        expect(
          authRedirect(AuthStatus.unauthenticated, '/login', requireAuth: true),
          isNull,
        );
        expect(
          authRedirect(
            AuthStatus.unauthenticated,
            '/onboarding',
            requireAuth: true,
          ),
          isNull,
        );
      },
    );

    test('ne redirige rien tant que le statut est inconnu', () {
      expect(
        authRedirect(AuthStatus.unknown, '/home', requireAuth: true),
        isNull,
      );
      expect(
        authRedirect(AuthStatus.unknown, '/login', requireAuth: true),
        isNull,
      );
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
