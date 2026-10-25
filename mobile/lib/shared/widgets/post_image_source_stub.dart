import 'package:flutter/material.dart';

/// Chargement d'une photo « locale » sur le web.
///
/// Sur web, il n'y a pas de système de fichiers : les aperçus choisis
/// arrivent sous forme de URLs résolubles par le navigateur (`blob:` d'un
/// picker, par exemple), donc on tente le réseau avec repli, ce qui tire
/// parti du chemin tel qu'il est fourni sans jamais faire échouer la carte.
Widget fileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  required Widget errorWidget,
}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => errorWidget,
  );
}
