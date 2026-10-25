import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/config/app_config.dart';
import 'package:uadb_social/core/navigation/app_nav.dart';
import 'package:uadb_social/core/router/app_router.dart';
import 'package:uadb_social/features/auth/state/auth_controller.dart';

void main() {
  // Mode sans session imposée : l'application est ouverte.
  String? open(String location) =>
      authRedirect(AuthStatus.unauthenticated, location, requireAuth: false);

  // Mode protégé : une session est exigée.
  String? guarded(AuthStatus status, String location) =>
      authRedirect(status, location, requireAuth: true);

  group('mode ouvert (REQUIRE_AUTH=false)', () {
    test('ne redirige aucune route, même protégée', () {
      for (final path in AppRoutes.protectedPaths) {
        expect(
          open(path),
          isNull,
          reason: '$path doit rester accessible sans session',
        );
      }
    });

    test('laisse aussi passer les écrans de connexion', () {
      for (final path in AppRoutes.publicPaths) {
        expect(open(path), isNull);
      }
    });

    test('est désactivé par défaut', () {
      expect(
        AppConfig.requireAuth,
        isTrue,
        reason: 'par défaut le splash mène à la connexion',
      );
    });
  });

  group('mode protégé (REQUIRE_AUTH=true)', () {
    test('ne redirige jamais /splash', () {
      for (final status in AuthStatus.values) {
        expect(
          guarded(status, AppRoutes.splash),
          isNull,
          reason: 'le splash anime la transition, une redirection le couperait',
        );
      }
    });

    test('renvoie un utilisateur connecté vers /home depuis une route publique', () {
      for (final path in [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.onboarding,
      ]) {
        expect(
          guarded(AuthStatus.authenticated, path),
          AppRoutes.home,
          reason: '$path est inutile une fois connecté',
        );
      }
    });

    test('renvoie un utilisateur non connecté vers /login depuis une route privée', () {
      for (final path in AppRoutes.protectedPaths) {
        expect(
          guarded(AuthStatus.unauthenticated, path),
          AppRoutes.login,
          reason: '$path ne doit pas être accessible sans session',
        );
      }
    });

    test('laisse un utilisateur connecté sur une route protégée', () {
      for (final path in AppRoutes.protectedPaths) {
        expect(guarded(AuthStatus.authenticated, path), isNull);
      }
    });

    test('laisse un utilisateur non connecté sur une route publique', () {
      for (final path in AppRoutes.publicPaths) {
        expect(guarded(AuthStatus.unauthenticated, path), isNull);
      }
    });

    test('ne redirige rien tant que le statut est inconnu', () {
      for (final path in [...AppRoutes.publicPaths, ...AppRoutes.protectedPaths]) {
        expect(
          guarded(AuthStatus.unknown, path),
          isNull,
          reason: 'un état inconnu ne doit pas provoquer de saut d’écran',
        );
      }
    });
  });

  group('AppRoutes', () {
    test('public et protégé ne se recoupent pas', () {
      expect(AppRoutes.publicPaths.intersection(AppRoutes.protectedPaths), isEmpty);
    });

    test('couvre les onglets et les écrans d’authentification', () {
      expect(AppRoutes.publicPaths, hasLength(5));
      expect(AppRoutes.protectedPaths, hasLength(5));
    });
  });

  group('AppTab', () {
    test('le bouton central est une action, pas un onglet', () {
      expect(AppTab.create.isAction, isTrue);
      for (final tab in AppTab.tabs.where((tab) => tab != AppTab.create)) {
        expect(tab.isAction, isFalse);
      }
    });

    test('chaque onglet pointe vers une route déclarée', () {
      for (final tab in AppTab.tabs) {
        expect(
          AppRoutes.protectedPaths,
          contains(tab.route),
          reason: '${tab.route} doit exister dans le routeur',
        );
      }
    });

    test('les emplacements 0 à 4 sont uniques', () {
      final slots = AppTab.tabs.map((tab) => tab.slot).toList();
      expect(slots.toSet(), hasLength(slots.length));
    });

    test('fromSlot retombe sur l’accueil pour un emplacement inconnu', () {
      expect(AppTab.fromSlot(0), AppTab.home);
      expect(AppTab.fromSlot(99), AppTab.home);
    });
  });

  group('profil de démonstration', () {
    test('permet à l’interface de s’afficher sans session', () {
      expect(demoProfile.fullName, isNotEmpty);
      expect(demoProfile.initials, isNotEmpty);
      expect(demoProfile.handle, startsWith('@'));
      expect(demoProfile.id, 'demo-user');
    });
  });
}
