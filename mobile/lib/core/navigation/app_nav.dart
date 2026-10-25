import 'package:flutter/material.dart';

/// Les cinq entrées de la barre de navigation, définies à un seul endroit.
///
/// L'index historique (0, 1, 2, 3, 4) est conservé : `2` est le bouton central
/// d'action, pas un onglet, et n'a donc pas de branche de route.
enum AppTab {
  home(0, 'Accueil', Icons.home_rounded, Icons.home_rounded, '/home'),
  explore(1, 'Explorer', Icons.explore_rounded, Icons.explore_rounded, '/explore'),
  create(2, 'Créer', Icons.add_rounded, Icons.add_rounded, '/create-post'),
  messages(
    3,
    'Messages',
    Icons.chat_bubble_outline_rounded,
    Icons.chat_bubble_rounded,
    '/messages',
  ),
  profile(
    4,
    'Profil',
    Icons.person_outline_rounded,
    Icons.person_rounded,
    '/profile',
  );

  const AppTab(this.slot, this.label, this.icon, this.activeIcon, this.route);

  /// Position dans la barre (0-4). Nommé `slot` car `index` est réservé par
  /// `Enum` ; l'index 2 est le bouton central, qui n'a pas de branche.
  final int slot;

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  bool get isAction => this == AppTab.create;

  /// Les onglets qui possèdent une branche dans le shell de navigation,
  /// dans l'ordre d'affichage (le bouton central est intercalé à l'affichage).
  static const List<AppTab> tabs = [
    AppTab.home,
    AppTab.explore,
    AppTab.create,
    AppTab.messages,
    AppTab.profile,
  ];

  static AppTab fromSlot(int slot) =>
      tabs.firstWhere((tab) => tab.slot == slot, orElse: () => AppTab.home);
}

/// Chemins des routes, regroupés pour éviter les chaînes magiques.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String createPost = '/create-post';
  static const String messages = '/messages';
  static const String profile = '/profile';

  /// Routes accessibles sans session.
  static const Set<String> publicPaths = {
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
  };

  /// Routes réservées aux utilisateurs connectés.
  static const Set<String> protectedPaths = {
    home,
    explore,
    createPost,
    messages,
    profile,
  };
}
