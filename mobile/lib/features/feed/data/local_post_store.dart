import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uadb_social/core/models/post.dart';

/// Stockage local des publications.
///
/// Tant qu'aucun serveur n'existe, le fil vit sur l'appareil : les
/// publications créées depuis l'app sont réellement conservées et réapparaissent
/// au redémarrage, au lieu d'être un simple affichage éphémère.
class LocalPostStore {
  LocalPostStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'posts.local';

  /// Version du contenu de démonstration embarqué.
  ///
  /// Un appareil qui a déjà lancé l'app conserve ses publications en
  /// mémoire ; sans ce compteur, une mise à jour de l'app (nouveau texte
  /// de démonstration, nouvelles images) ne remplacerait jamais les
  /// vieilles publications démo — c'est ce qui faisait s'afficher l'ancien
  /// fil après chaque évolution. Incrémenter cette constante déclenche le
  /// remplacement des démos côté [FeedController], en préservant tout ce
  /// que l'utilisateur a publié lui-même.
  static const int schemaVersion = 2;

  static const String versionKey = 'posts.schema_version';

  int readSchemaVersion() => _prefs.getInt(versionKey) ?? 0;

  Future<void> writeSchemaVersion(int value) =>
      _prefs.setInt(versionKey, value);

  List<Post> readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<Object?>)
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> writeAll(List<Post> posts) =>
      _prefs.setString(storageKey, jsonEncode(posts.map(_toJson).toList()));

  Future<void> clear() => _prefs.remove(storageKey);

  /// Sérialisation explicite : le fil doit survivre à un redémarrage, donc on
  /// ne peut pas se contenter de `toJson()` par défaut sans conserver
  /// l'horodatage.
  static Map<String, dynamic> _toJson(Post post) => {
    'id': post.id,
    'authorId': post.authorId,
    'authorName': post.authorName,
    'authorRole': post.authorRole,
    'createdAt': post.createdAt?.toIso8601String(),
    'content': post.content,
    'imageUrls': post.imageUrls,
    'isOfficial': post.isOfficial,
    'likesCount': post.likesCount,
    'commentsCount': post.commentsCount,
    'sharesCount': post.sharesCount,
    'likedByMe': post.likedByMe,
    if (post.avatarColor != null) 'avatarColor': post.avatarColor,
  };

  static Post _fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] == null
        ? null
        : DateTime.tryParse(json['createdAt'].toString());
    return Post(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'Utilisateur',
      authorRole: json['authorRole']?.toString() ?? '',
      createdAt: createdAt,
      content: json['content']?.toString() ?? '',
      imageUrls: (json['imageUrls'] as List<Object?>? ?? const [])
          .map((url) => url.toString())
          .toList(),
      isOfficial: json['isOfficial'] == true,
      likesCount: json['likesCount'] is int ? json['likesCount']! as int : 0,
      commentsCount: json['commentsCount'] is int
          ? json['commentsCount']! as int
          : 0,
      sharesCount: json['sharesCount'] is int ? json['sharesCount']! as int : 0,
      likedByMe: json['likedByMe'] == true,
      avatarColor: json['avatarColor']?.toString(),
    );
  }
}

/// Contenu de démonstration servi au premier lancement.
///
/// L'écran d'accueil le signale explicitement, pour qu'il ne soit jamais confondu
/// avec un fil réel.
///
/// Les trois publications reprennent la structure de la maquette de
/// référence : une réussite en hackathon illustrée de deux photos, un
/// communiqué officiel sans image, puis une activité de recherche avec une
/// image pleine largeur. Les photos sont embarquées dans les assets
/// (`assets/…`) plutôt que servies par une URL distante, afin que le fil
/// reste illustré hors ligne et qu'aucun lien ne puisse disparaître.
List<Post> demoFeed(DateTime now) => [
  Post(
    id: 'demo-aminata',
    authorId: 'demo-aminata',
    authorName: 'Aminata Diallo',
    // Reproduction de la capture de référence : « Licence 3 Informat... ».
    authorRole: 'Licence 3 Informatique',
    createdAt: now.subtract(const Duration(hours: 2)),
    content:
        'Félicitations à toute l’équipe de l’UADB qui a remporté le deuxième '
        'prix au hackathon de Dakar ! Notre application d’irrigation '
        'intelligente pour Bambey a séduit le jury. 🎉🚜',
    imageUrls: const ['assets/demo_event.jpg', 'assets/demo_solar.jpg'],
    // La capture affiche un cœur rouge avec « 24 » et « 8 » : la
    // publication est aimée et le compteur vient des données, là aussi.
    likedByMe: true,
    likesCount: 24,
    commentsCount: 8,
    sharesCount: 6,
  ),
  Post(
    id: 'demo-scolarite',
    authorId: 'demo-scolarite',
    authorName: 'Direction Scolarité',
    authorRole: 'Direction de la Scolarité',
    createdAt: now.subtract(const Duration(hours: 5)),
    content:
        'Communiqué : le calendrier des examens du semestre est disponible. '
        'Le planning par faculté est affiché aux tableaux d’information et '
        'consultable auprès de la Direction de la Scolarité.',
    isOfficial: true,
    // La maquette fixe un avatar orange pour ce compte officiel.
    avatarColor: '#F59E0B',
    likesCount: 12,
    commentsCount: 3,
    sharesCount: 18,
  ),
  Post(
    id: 'demo-moussa',
    authorId: 'demo-moussa',
    authorName: 'Moussa Ndiaye',
    authorRole: 'Licence 3 Agronomie',
    createdAt: now.subtract(const Duration(hours: 20)),
    content:
        'Activité de recherche agricole sur la parcelle expérimentale : suivi '
        'de la croissance des cultures et échange avec les producteurs du '
        'village.',
    imageUrls: const ['assets/demo_field.jpg'],
    likesCount: 33,
    commentsCount: 7,
    sharesCount: 4,
  ),
];
