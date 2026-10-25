import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post.dart';
import '../../../core/providers.dart';
import '../data/local_post_store.dart';

final localPostStoreProvider = Provider<LocalPostStore>(
  (ref) => LocalPostStore(ref.watch(tokenStoreProvider).preferences),
);

/// Fil d'actualité local.
///
/// Aucun appel réseau : le fil est lu depuis le stockage de l'appareil, et les
/// publications créées dans l'app y sont écrites. Au premier lancement, un
/// contenu de démonstration est injecté et signalé comme tel à l'écran.
class FeedController extends Notifier<List<Post>> {
  @override
  List<Post> build() {
    final store = ref.watch(localPostStoreProvider);
    final stored = store.readAll();

    // Migration : si le contenu de démonstration a changé depuis la
    // dernière exécution de l'app (cf. [LocalPostStore.schemaVersion]),
    // les publications de démonstration stockées sont remplacées par la
    // version récente. Sans cela, l'appareil afficherait indéfiniment
    // l'ancien fil — sans image, avec l'ancien texte — même après mise à
    // jour. Les publications créées par l'utilisateur sont conservées.
    if (store.readSchemaVersion() < LocalPostStore.schemaVersion) {
      final userPosts = [
        for (final post in stored)
          if (!post.id.startsWith('demo-')) post,
      ];
      final migrated = [...demoFeed(DateTime.now()), ...userPosts];
      store.writeAll(migrated);
      store.writeSchemaVersion(LocalPostStore.schemaVersion);
      return migrated;
    }

    if (stored.isNotEmpty) return stored;

    final seeded = demoFeed(DateTime.now());
    store.writeAll(seeded);
    store.writeSchemaVersion(LocalPostStore.schemaVersion);
    return seeded;
  }

  /// Vrai tant que le fil n'a pas été alimenté que par le contenu de
  /// démonstration, et qu'aucune publication n'a été ajoutée par l'utilisateur.
  bool get isDemoOnly => state.every((post) => post.id.startsWith('demo-'));

  void add(Post post) {
    state = [post, ...state];
    ref.read(localPostStoreProvider).writeAll(state);
  }

  /// Bascule le like et conserve le choix localement.
  void toggleLike(String postId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(
            likedByMe: !post.likedByMe,
            likesCount: post.likesCount + (post.likedByMe ? -1 : 1),
          )
        else
          post,
    ];
    ref.read(localPostStoreProvider).writeAll(state);
  }

  void share(String postId) {
    state = [
      for (final post in state)
        if (post.id == postId)
          post.copyWith(sharesCount: post.sharesCount + 1)
        else
          post,
    ];
    ref.read(localPostStoreProvider).writeAll(state);
  }

  /// Réinitialise le fil sur le contenu de démonstration.
  void resetToDemo() {
    final seeded = demoFeed(DateTime.now());
    ref.read(localPostStoreProvider).writeAll(seeded);
    state = seeded;
  }
}

final feedProvider = NotifierProvider<FeedController, List<Post>>(
  FeedController.new,
);
