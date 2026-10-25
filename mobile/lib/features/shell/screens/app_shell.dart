import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_nav.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../profile/state/messages_badge.dart';

/// Coquille des onglets.
///
/// Définit **une seule** barre de navigation pour toute l'app (fini le
/// `_onNavTap` dupliqué dans les cinq écrans) et conserve l'état de chaque
/// onglet lors des bascules.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTabTap(BuildContext context, AppTab tab) {
    if (tab.isAction) {
      // Le bouton central empile le flux de publication au-dessus du shell :
      // `context.pop()` ramène donc l'utilisateur sur son onglet d'origine.
      context.pushNamed('create-post');
      return;
    }

    final branchIndex = _branchIndexFor(tab);
    // Re-taper sur l'onglet actif le ramène à sa racine.
    final alreadyActive = navigationShell.currentIndex == branchIndex;
    navigationShell.goBranch(branchIndex, initialLocation: alreadyActive);
  }

  /// Les branches du `StatefulShellRoute`, dans l'ordre de déclaration.
  static int _branchIndexFor(AppTab tab) => switch (tab) {
    AppTab.home => 0,
    AppTab.explore => 1,
    AppTab.messages => 2,
    AppTab.profile => 3,
    AppTab.create => throw ArgumentError(
      'Le bouton central ne correspond à aucune branche.',
    ),
  };

  static AppTab _tabForBranch(int index) => switch (index) {
    0 => AppTab.home,
    1 => AppTab.explore,
    2 => AppTab.messages,
    _ => AppTab.profile,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = _tabForBranch(navigationShell.currentIndex);
    final unreadCount = ref.watch(unreadMessagesProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: activeTab.slot,
        onTap: (slot) => _onTabTap(context, AppTab.fromSlot(slot)),
        messagesBadgeCount: unreadCount,
      ),
    );
  }
}
