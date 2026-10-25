import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/local_saved_store.dart';

final savedStoreProvider = Provider<LocalSavedStore>(
  (ref) => LocalSavedStore(ref.watch(tokenStoreProvider).preferences),
);

/// Identifiants des publications enregistrées par l'utilisateur.
///
/// Un simple ensemble d'identifiants, persisté localement : la carte de
/// publication en est informée via l'appelant (voir [isSaved]),
/// sans dépendre elle-même du stockage.
class SavedPostsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final saved = ref.watch(savedStoreProvider).readSaved();
    return saved;
  }

  bool isSaved(String postId) => state.contains(postId);

  /// Bascule l'enregistrement d'une publication et conserve le choix
  /// localement : le favori survit à une relance de l'application.
  void toggle(String postId) {
    final next = Set<String>.of(state);
    // `remove` ne renvoie vrai que si l'identifiant était présent : sinon
    // il faut l'ajouter pour basculer l'état.
    if (!next.remove(postId)) next.add(postId);
    state = next;
    ref.read(savedStoreProvider).writeSaved(next);
  }
}

final savedIdsProvider = NotifierProvider<SavedPostsController, Set<String>>(
  SavedPostsController.new,
);
