import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadb_social/core/models/post.dart';
import 'package:uadb_social/core/providers.dart';
import 'package:uadb_social/core/services/token_store.dart';
import 'package:uadb_social/features/feed/data/local_post_store.dart';
import 'package:uadb_social/features/feed/state/feed_controller.dart';

void main() {
  late TokenStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await TokenStore.create();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [tokenStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LocalPostStore', () {
    test('ne renvoie rien au premier lancement', () {
      expect(LocalPostStore(store.preferences).readAll(), isEmpty);
    });

    test('effectue un aller-retour JSON fidèle', () async {
      final posts = <Post>[
        Post(
          id: 'p1',
          authorId: 'u1',
          authorName: 'Fatou Sow',
          authorRole: 'Informatique',
          // `DateTime(...)` n'est pas une constante de compilation.
          createdAt: DateTime(2026, 9, 25, 14, 30),
          content: 'Bonjour',
          isOfficial: true,
          likesCount: 4,
          commentsCount: 2,
          sharesCount: 1,
          likedByMe: true,
        ),
      ];

      final postsStore = LocalPostStore(store.preferences);
      await postsStore.writeAll(posts);

      final restored = postsStore.readAll().single;

      expect(restored.id, 'p1');
      expect(restored.content, 'Bonjour');
      expect(restored.authorRole, 'Informatique');
      expect(restored.createdAt, DateTime(2026, 9, 25, 14, 30));
      expect(restored.isOfficial, isTrue);
      expect(restored.likesCount, 4);
      expect(restored.likedByMe, isTrue);
    });

    test('conserve plusieurs images', () async {
      final postsStore = LocalPostStore(store.preferences);
      await postsStore.writeAll([
        const Post(
          id: 'p2',
          authorId: 'u1',
          authorName: 'Moi',
          content: 'x',
          imageUrls: ['/tmp/a.png', '/tmp/b.png'],
        ),
      ]);

      expect(postsStore.readAll().single.imageUrls, [
        '/tmp/a.png',
        '/tmp/b.png',
      ]);
    });

    test('reste tolérant à un stockage corrompu', () {
      store.preferences.setString(LocalPostStore.storageKey, 'pas du json');
      expect(LocalPostStore(store.preferences).readAll(), isEmpty);
    });
  });

  group('contenu de démonstration', () {
    test('propose des publications horodatées', () {
      final feed = demoFeed(DateTime(2026, 9, 25, 12));

      expect(feed, isNotEmpty);
      for (final post in feed) {
        expect(post.id, startsWith('demo-'));
        expect(post.createdAt, isNotNull);
        expect(post.content, isNotEmpty);
      }
    });
  });

  group('FeedController', () {
    test('amorce le fil avec le contenu de démonstration', () {
      final container = buildContainer();
      final posts = container.read(feedProvider);

      expect(posts, isNotEmpty);
      expect(container.read(feedProvider.notifier).isDemoOnly, isTrue);
    });

    test('n’est plus « démo uniquement » dès qu’on publie', () {
      final container = buildContainer();
      container
          .read(feedProvider.notifier)
          .add(
            const Post(
              id: 'p-mine',
              authorId: 'u1',
              authorName: 'Moi',
              content: 'Ma publication',
            ),
          );

      expect(container.read(feedProvider.notifier).isDemoOnly, isFalse);
    });

    test('add place la publication en tête de fil', () {
      final container = buildContainer();
      final before = container.read(feedProvider).length;

      container
          .read(feedProvider.notifier)
          .add(
            const Post(
              id: 'p-mine',
              authorId: 'u1',
              authorName: 'Moi',
              content: 'Ma publication',
            ),
          );

      final posts = container.read(feedProvider);
      expect(posts.length, before + 1);
      expect(posts.first.id, 'p-mine');
    });

    test('la publication est persistée et relue après relance', () {
      final container = buildContainer();
      container
          .read(feedProvider.notifier)
          .add(
            const Post(
              id: 'p-mine',
              authorId: 'u1',
              authorName: 'Moi',
              content: 'Ma publication',
            ),
          );

      // Nouveau conteneur, même stockage : la publication doit être là.
      final reopened = buildContainer();
      expect(reopened.read(feedProvider).first.id, 'p-mine');
    });

    test('toggleLike incrémente puis décrémente', () {
      final container = buildContainer();
      // La première publication de démonstration est déjà aimée (cœur rouge
      // de la maquette de référence) : la bascule est vérifiée sur une
      // publication non aimée, pour partir de l'état normal.
      final id = container
          .read(feedProvider)
          .where((post) => !post.likedByMe)
          .first
          .id;
      final initial = container
          .read(feedProvider)
          .firstWhere((p) => p.id == id)
          .likesCount;

      container.read(feedProvider.notifier).toggleLike(id);
      final liked = container.read(feedProvider).firstWhere((p) => p.id == id);
      expect(liked.likedByMe, isTrue);
      expect(liked.likesCount, initial + 1);

      container.read(feedProvider.notifier).toggleLike(id);
      final unliked = container
          .read(feedProvider)
          .firstWhere((p) => p.id == id);
      expect(unliked.likedByMe, isFalse);
      expect(unliked.likesCount, initial);
    });

    test('le like survit à une relance', () {
      final container = buildContainer();
      // Même ciblage que ci-dessus : la première publication est déjà aimée
      // dans le contenu de démonstration.
      final id = container
          .read(feedProvider)
          .where((post) => !post.likedByMe)
          .first
          .id;

      container.read(feedProvider.notifier).toggleLike(id);

      final reopened = buildContainer();
      expect(
        reopened.read(feedProvider).firstWhere((p) => p.id == id).likedByMe,
        isTrue,
      );
    });

    test('share incrémente le compteur de partage', () {
      final container = buildContainer();
      final id = container.read(feedProvider).first.id;
      final initial = container.read(feedProvider).first.sharesCount;

      container.read(feedProvider.notifier).share(id);

      expect(
        container.read(feedProvider).firstWhere((p) => p.id == id).sharesCount,
        initial + 1,
      );
    });

    test('ne touche que la publication visée', () {
      final container = buildContainer();
      final posts = container.read(feedProvider);
      final target = posts.first.id;
      final untouchedBefore = posts.last;

      container.read(feedProvider.notifier).toggleLike(target);

      final untouchedAfter = container
          .read(feedProvider)
          .firstWhere((p) => p.id == untouchedBefore.id);
      expect(untouchedAfter.likedByMe, untouchedBefore.likedByMe);
      expect(untouchedAfter.likesCount, untouchedBefore.likesCount);
    });

    test('resetToDemo repart du contenu initial', () {
      final container = buildContainer();
      container
          .read(feedProvider.notifier)
          .add(
            const Post(
              id: 'p-mine',
              authorId: 'u1',
              authorName: 'Moi',
              content: 'Ma publication',
            ),
          );

      container.read(feedProvider.notifier).resetToDemo();

      final posts = container.read(feedProvider);
      expect(posts.every((post) => post.id.startsWith('demo-')), isTrue);
    });

    test('ne lève aucune exception de réseau', () {
      // L'application ne doit plus faire d'appel HTTP : le fil se construit
      // de façon synchrone, sans état de chargement ni erreur.
      final container = buildContainer();
      expect(container.read(feedProvider), isA<List<Post>>());
    });
  });
}
