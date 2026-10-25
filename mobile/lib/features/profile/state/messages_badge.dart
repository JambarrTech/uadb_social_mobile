import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// Nombre de conversations non lues, lu depuis le stockage local.
///
/// Exposé pour le badge de la barre de navigation. Le backend n'expose pas
/// encore d'endpoint de messagerie : la valeur est donc persistée localement
/// et mise à jour par [UnreadMessagesController].
final unreadMessagesProvider = Provider<int>(
  (ref) => ref.watch(tokenStoreProvider).unreadMessagesCount,
);

class UnreadMessagesController extends Notifier<int> {
  @override
  int build() => ref.read(tokenStoreProvider).unreadMessagesCount;

  Future<void> setCount(int value) async {
    state = value < 0 ? 0 : value;
    await ref.read(tokenStoreProvider).setUnreadMessagesCount(state);
  }

  Future<void> markAllRead() => setCount(0);
}

final unreadMessagesControllerProvider =
    NotifierProvider<UnreadMessagesController, int>(
      UnreadMessagesController.new,
    );
