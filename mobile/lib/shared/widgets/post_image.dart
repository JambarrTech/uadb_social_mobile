import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'post_image_source.dart';

/// Affiche une image de publication quel que soit son origine :
///
/// - URL distante (`http(s)://…`) : chargement réseau, avec un état
///   d'attente discret et un repli en cas d'erreur ;
/// - photo embarquée (`assets/…`) : asset local ;
/// - photo choisie sur l'appareil (chemin de fichier `/data/…`,
///   `file://…`, blob web) : rendue via [fileImage]. Avant ce widget, les
///   publications créées depuis l'app recevaient leur chemin de fichier
///   là où tout le reste attendait une URL : la carte affichait
///   systématiquement son repli d'erreur, d'où des publications
///   « sans images ».
///
/// L'alternative est [`Image.network`] telle quelle : une erreur de
/// chargement ne casse pas la mise en page, elle affiche le repli.
class PostImage extends StatelessWidget {
  const PostImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  static bool _isHttp(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  /// Chemin accessible par le système de fichier de la plateforme web
  /// (blob d'un aperçu choisi) ou par `dart:io` partout ailleurs.
  static bool _isLocalFile(String url) =>
      url.startsWith('/') || url.startsWith('file:') || url.startsWith('blob:');

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _Fallback();

    if (_isHttp(url) || url.startsWith('blob:')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        // Repli : une image inaccessible ne doit jamais faire échouer la
        // carte (aspect, hauteur, largeur restent stables).
        errorBuilder: (context, _, _) =>
            _Fallback(width: width, height: height),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _Fallback(width: width, height: height),
      );
    }

    if (!_isLocalFile(url)) {
      // Chemin relatif : assets embarqués du projet (`assets/demo_…`).
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, _) =>
            _Fallback(width: width, height: height),
      );
    }

    // Photo de l'appareil : le chargement passe par le fichier local là où
    // la plateforme le permet (voir post_image_source.dart).
    return fileImage(
      path: url,
      width: width,
      height: height,
      fit: fit,
      errorWidget: _Fallback(width: width, height: height),
    );
  }
}

/// Repli visuel stable quand l'image est indisponible (prévue vide, en
/// réseau, ou asset manquant) : zone grisée avec icône discrète.
///
/// Sans taille fournie (ex. visionneuse plein écran), le repli occupe une
/// vignette bornée pour ne jamais déborder en contrainte non bornée.
class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 120,
      height: height ?? 120,
      child: const ColoredBox(
        color: AppColors.borderSeparator,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
