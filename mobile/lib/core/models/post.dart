import 'json_utils.dart';

/// Visibilité d'une publication.
///
/// Le backend attend des valeurs techniques : les libellés français ne sont
/// manipulés que dans l'UI, jamais envoyés tels quels.
enum PostVisibility {
  public('public', 'Tout le monde'),
  friends('friends', 'Amis'),
  communities('communities', 'Communautés'),
  private('private', 'Moi uniquement');

  const PostVisibility(this.apiValue, this.label);

  /// Valeur transmise à l'API.
  final String apiValue;

  /// Libellé affiché dans le sélecteur.
  final String label;

  static PostVisibility fromApi(String? value) =>
      PostVisibility.values.firstWhere(
        (item) => item.apiValue == value?.toString().toLowerCase(),
        orElse: () => PostVisibility.public,
      );
}

/// Une publication du fil.
class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorRole = 'Membre UADB',
    this.createdAt,
    required this.content,
    this.imageUrls = const [],
    this.isOfficial = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedByMe = false,
    this.legacyTimeAgo,
    this.avatarColor,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final DateTime? createdAt;
  final String content;
  final List<String> imageUrls;
  final bool isOfficial;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool likedByMe;

  /// Repli textuel fourni par le backend quand aucun horodatage n'est
  /// exploitable (« il y a 3h »).
  final String? legacyTimeAgo;

  /// Couleur d'avatar imposée par la maquette, au format `#RRGGBB`.
  ///
  /// Facultatif et purement présentationnel : quand il est absent, l'avatar
  /// choisit sa teinte à partir des initiales. Il sert notamment aux comptes
  /// officiels dont la maquette fixe une couleur propre (la Direction de la
  /// Scolarité, par exemple, apparaît en orange).
  final String? avatarColor;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: readFirstString(json, const ['id', '_id']),
    authorId: readFirstString(json, const ['authorId', 'userId', '_userId']),
    authorName: readFirstString(json, const [
      'authorName',
      'author',
      'userName',
    ]),
    authorRole: readFirstString(json, const [
      'authorRole',
      'role',
      'department',
    ]),
    createdAt: _parseDate(json),
    content: readFirstString(json, const ['content', 'text', 'body']),
    imageUrls: _parseImages(json),
    isOfficial: readFirstBool(json, const ['isOfficial', 'official']),
    likesCount: readFirstInt(json, const [
      'likesCount',
      'likes',
      'likes_count',
    ]),
    commentsCount: readFirstInt(json, const [
      'commentsCount',
      'comments',
      'comments_count',
    ]),
    sharesCount: readFirstInt(json, const [
      'sharesCount',
      'shares',
      'shares_count',
    ]),
    likedByMe: readFirstBool(json, const [
      'likedByMe',
      'liked',
      'isLiked',
      'hasLiked',
    ]),
    legacyTimeAgo: readFirstString(json, const ['timeAgo', 'time_ago']),
    avatarColor: readFirstNullableString(json, const [
      'avatarColor',
      'avatar_color',
    ]),
  );

  static DateTime? _parseDate(Map<String, dynamic> json) {
    final raw = readFirst(json, const [
      'createdAt',
      'created_at',
      'publishedAt',
      'date',
    ]);
    if (raw is num) {
      // Timestamp Unix, en millisecondes ou en secondes.
      final millis = raw > 1e11 ? raw.toInt() : raw.toInt() * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    final value = readString(raw);
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static List<String> _parseImages(Map<String, dynamic> json) {
    final raw = readFirst(json, const [
      'imageUrls',
      'images',
      'media',
      'imageUrl',
    ]);
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .map(readString)
          .where((url) => url.isNotEmpty)
          .toList(growable: false);
    }
    // L'API historique renvoyait une liste d'URL séparée par des virgules.
    return readString(raw)
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  /// Horodatage lisible (« il y a 3 h »), calculé si possible.
  String timeAgo({DateTime? now}) {
    final moment = createdAt;
    if (moment == null) return legacyTimeAgo ?? "à l'instant";
    return formatTimeAgo(moment, now: now);
  }

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? likedByMe,
  }) => Post(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorRole: authorRole,
    createdAt: createdAt,
    content: content,
    imageUrls: imageUrls,
    isOfficial: isOfficial,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount ?? this.commentsCount,
    sharesCount: sharesCount ?? this.sharesCount,
    likedByMe: likedByMe ?? this.likedByMe,
    legacyTimeAgo: legacyTimeAgo,
    avatarColor: avatarColor,
  );
}

const List<String> _shortMonths = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// Formate un écart temporel en français de façon compacte.
String formatTimeAgo(DateTime moment, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(moment);

  if (diff.isNegative) return "à l'instant";
  if (diff.inSeconds < 60) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';

  if (diff.inDays < 7) return 'il y a ${diff.inDays} j';

  final local = moment.toLocal();
  final sameYear = local.year == reference.year;
  final day = local.day.toString().padLeft(2, '0');
  final month = _shortMonths[local.month - 1];
  return sameYear ? '$day $month' : '$day $month ${local.year}';
}
