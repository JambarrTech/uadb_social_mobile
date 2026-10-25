import 'dart:io';

import 'package:flutter/material.dart';

/// Chargement d'une photo choisie sur l'appareil, via [dart:io] (Android,
/// iOS, bureau). Le chargement réseau n'existe pas ici : un chemin de
/// fichier doit être lu localement.
Widget fileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  required Widget errorWidget,
}) {
  return Image.file(
    File(path.startsWith('file:') ? Uri.parse(path).toFilePath() : path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => errorWidget,
  );
}
