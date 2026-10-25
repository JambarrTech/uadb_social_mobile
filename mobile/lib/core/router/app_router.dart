import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/create/screens/create_post_screen.dart';
import '../../features/explore/screens/explorer_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/messages_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/shell/screens/app_shell.dart';
import '../config/app_config.dart';
import '../navigation/app_nav.dart';

/// Clés de navigation interne permettant au shell de piloter les branches.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'branch-home');
final _exploreNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'branch-explore',
);
final _messagesNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'branch-messages',
);
final _profileNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'branch-profile',
);

/// Redirection d'authentification.
///
/// Ne s'applique que si [AppConfig.requireAuth] est actif. Sinon l'application
/// est ouverte : toutes les routes sont accessibles, y compris les écrans de
/// connexion, qui restent présents mais ne sont plus imposés.
///
/// Règles lorsqu'elle s'applique :
/// - `/splash` n'est jamais redirigée : l'écran décide lui-même de la
///   destination (animée), ce qui évite un saut brutal au démarrage ;
/// - un utilisateur connecté est renvoyé vers `/home` s'il ouvre une route
///   publique (login, register…) ;
/// - un utilisateur non connecté est renvoyé vers `/login` s'il ouvre une
///   route protégée.
String? authRedirect(
  AuthStatus status,
  String location, {
  required bool requireAuth,
}) {
  if (!requireAuth) return null;
  if (status == AuthStatus.unknown) return null;
  if (location == AppRoutes.splash) return null;

  final isPublic = AppRoutes.publicPaths.contains(location);
  final isProtected = AppRoutes.protectedPaths.contains(location);

  if (status == AuthStatus.authenticated && isPublic) {
    return AppRoutes.home;
  }
  if (status == AuthStatus.unauthenticated && isProtected) {
    return AppRoutes.login;
  }
  return null;
}

/// Routeur applicatif : gardes d'authentification + shell d'onglets.
///
/// Les quatre onglets vivent dans un [StatefulShellRoute] afin de conserver
/// leur état (position de défilement, filtres) lors des bascules, et de
/// n'avoir qu'une seule barre de navigation à définir.
GoRouter buildRouter(Ref ref) {
  // `refreshListenable` demande un `Listenable`. On bricole un notifier
  // alimenté par `ref.listen` afin que tout changement de statut
  // d'authentification ré-evalue les redirections.
  final authChanges = ValueNotifier<int>(0);
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) => authChanges.value++,
  );
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      return authRedirect(
        status,
        state.matchedLocation,
        requireAuth: AppConfig.requireAuth,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Flux modal empilé au-dessus du shell : `context.pop()` retrouve donc
      // l'onglet d'origine au lieu de retomber sur la route initiale.
      //
      // Le composeur de l'accueil peut demander l'ouverture immédiate du
      // sélecteur d'images (`extra['openImagePicker']`) : c'est le bouton
      // « Photo » de la carte de création, qui réutilise ce même écran et le
      // même flux de galerie au lieu d'une logique dupliquée.
      GoRoute(
        path: AppRoutes.createPost,
        name: 'create-post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final openImagePicker =
              extra is Map && extra['openImagePicker'] == true;
          return CreatePostScreen(autoPickImages: openImagePicker);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _exploreNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                name: 'explore',
                builder: (context, state) => const ExplorerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _messagesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                name: 'messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final goRouterProvider = Provider<GoRouter>(buildRouter);
