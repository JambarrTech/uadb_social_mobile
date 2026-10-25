import 'package:flutter_test/flutter_test.dart';
import 'package:uadb_social/core/models/auth_user.dart';
import 'package:uadb_social/core/models/post.dart';

void main() {
  group('AuthUser', () {
    test('compose le nom depuis firstName / lastName', () {
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

    test('tolère un booléen sérialisé en chaîne', () {
      final user = AuthUser.fromJson({
        'id': 'u2',
        'email': 'awa@uadb.edu.sn',
        'fullName': 'Awa Diop',
        'isOfficial': 'true',
      });

      expect(user.isOfficial, isTrue);
    });

    test('retombe sur un nom par défaut si le backend n’envoie rien', () {
      final user = AuthUser.fromJson({'id': 'u3', 'email': 'x@y.sn'});

      expect(user.fullName, 'Membre UADB');
      expect(user.initials, isNotEmpty);
      expect(user.handle, '@x');
    });

    test('accepte les variantes de clés du backend', () {
      final user = AuthUser.fromJson({
        '_id': 'u4',
        'username': 'Matar Mbow',
        'email': 'matar@uadb.edu.sn',
        'filiere': 'Informatique',
        'avatar': 'https://cdn/a.png',
      });

      expect(user.id, 'u4');
      expect(user.fullName, 'Matar Mbow');
      expect(user.department, 'Informatique');
      expect(user.avatarUrl, 'https://cdn/a.png');
    });

    test('effectue un aller-retour JSON stable', () {
      const user = AuthUser(
        id: 'u5',
        email: 'a@b.sn',
        fullName: 'Awa Diop',
        department: 'Droit',
      );

      expect(AuthUser.fromJson(user.toJson()), user);
    });
  });

  group('Post', () {
    test('analyse une publication avec horodatage et images', () {
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

      expect(post.likesCount, 12, reason: 'un nombre en chaîne doit être lu');
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

    test('accepte un timestamp Unix exprimé en secondes', () {
      final post = Post.fromJson({
        'id': 'p3',
        'content': 'x',
        'createdAt': 1767225600,
      });

      expect(post.createdAt, isNotNull);
      expect(post.timeAgo(), isNotEmpty);
    });

    test('repli sur timeAgo quand aucun horodatage n’est exploitable', () {
      final post = Post.fromJson({
        'id': 'p4',
        'content': 'x',
        'timeAgo': 'il y a 3h',
      });

      expect(post.timeAgo(), 'il y a 3h');
    });

    test('copyWith ne modifie que les champs fournis', () {
      final post = Post.fromJson({
        'id': 'p5',
        'content': 'x',
        'likesCount': 3,
      });

      final liked = post.copyWith(likesCount: 4, likedByMe: true);

      expect(liked.likesCount, 4);
      expect(liked.likedByMe, isTrue);
      expect(liked.content, 'x');
      expect(liked.id, 'p5');
    });
  });

  group('formatTimeAgo', () {
    final now = DateTime(2026, 9, 25, 12);

    test('formate les unités de temps', () {
      expect(formatTimeAgo(now.subtract(const Duration(seconds: 10)), now: now),
          "à l'instant");
      expect(formatTimeAgo(now.subtract(const Duration(minutes: 5)), now: now),
          'il y a 5 min');
      expect(formatTimeAgo(now.subtract(const Duration(hours: 3)), now: now),
          'il y a 3 h');
      expect(formatTimeAgo(now.subtract(const Duration(days: 2)), now: now),
          'il y a 2 j');
    });

    test('bascule sur une date au-delà d’une semaine', () {
      final older = formatTimeAgo(
        DateTime(2026, 8, 3),
        now: now,
      );
      expect(older, '03 août');
    });

    test('ajoute l’année pour une date antérieure', () {
      expect(formatTimeAgo(DateTime(2024, 12, 24), now: now), '24 déc. 2024');
    });
  });

  group('PostVisibility', () {
    test('associe chaque libellé français à une valeur technique', () {
      expect(PostVisibility.public.apiValue, 'public');
      expect(PostVisibility.friends.apiValue, 'friends');
      expect(PostVisibility.communities.apiValue, 'communities');
      expect(PostVisibility.private.apiValue, 'private');
    });

    test('aucune valeur technique ne contient d’espace', () {
      for (final visibility in PostVisibility.values) {
        expect(
          visibility.apiValue,
          isNot(contains(' ')),
          reason: 'le backend ne doit jamais recevoir « ${visibility.label} »',
        );
      }
    });

    test('reconnaît une valeur API inconnue sans planter', () {
      expect(PostVisibility.fromApi('friends'), PostVisibility.friends);
      expect(PostVisibility.fromApi('inconnu'), PostVisibility.public);
      expect(PostVisibility.fromApi(null), PostVisibility.public);
    });
  });
}
