import 'package:flutter/material.dart';

/// Seuils de mise en page.
///
/// En dessous de [compact] on est sur un téléphone, jusqu'à [medium] une
/// tablette, au-delà un affichage large (web, desktop).
abstract final class Breakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1280;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

/// Largeur maximale du contenu sur un écran large.
///
/// Remplace les largeurs fixes (342, 358…) qui débordaient dès que la fenêtre
/// dépassait ~390 px.
abstract final class ContentWidth {
  /// Formulaires et écrans d'authentification.
  static const double form = 420;

  /// Colonnes de contenu principals (fil, exploration).
  static const double feed = 640;

  /// Cartes et panneaux.
  static const double card = 480;
}

/// Corps de page centré et contraint en largeur.
///
/// ```dart
/// Scaffold(
///   body: AppPage(
///     child: Column(...),
///   ),
/// )
/// ```
///
/// - sur téléphone : occupe toute la largeur, avec le padding horizontal ;
/// - sur tablette / web : la colonne est centrée et plafonnée à [maxWidth].
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.maxWidth = ContentWidth.form,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.scrollable = true,
    this.verticalPadding = 24,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;

  /// Marge horizontale appliquée sur téléphone. Doit être symétrique
  /// (`EdgeInsets.symmetric`) : seule la valeur de gauche est reprise.
  final EdgeInsets padding;

  final bool scrollable;
  final double verticalPadding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    // Seul le côté gauche de [padding] est repris : le padding attendu est
    // symétrique (`EdgeInsets.symmetric`). `EdgeInsets.horizontal` conviendrait
    // mal, car cette propriété renvoie la somme des deux côtés.
    final horizontal = Breakpoints.isCompact(context) ? padding.left : 0.0;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: verticalPadding,
      ),
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          // `double.infinity` sous une contrainte-max : la colonne occupe toute
          // la largeur disponible, plafonnée à [maxWidth]. Sans cela, un enfant
          // qui ne s'étire pas (un `Text`, une `Row`) ferait rétrécir la
          // colonne à sa largeur intrinsèque.
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );

    if (!scrollable) return content;
    return SingleChildScrollView(child: content);
  }
}

/// Largeur de champ à utiliser dans un formulaire.
///
/// Aligne la largeur sur le contenu du parent au lieu d'imposer une valeur
/// fixe.
class FormFieldBox extends StatelessWidget {
  const FormFieldBox({super.key, required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(width: double.infinity, child: child);
    return height == null ? box : SizedBox(height: height, child: box);
  }
}
