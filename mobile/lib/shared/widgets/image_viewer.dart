import 'package:flutter/material.dart';

import 'post_image.dart';

/// Visionneuse plein écran des images d'une publication.
///
/// Lancée depuis la galerie d'une [PostCard] : défilement horizontal entre
/// les images, pincement pour zoomer, indicateur « 1 / 2 ».
/// Le mécanisme d'ouverture est déterministe : asset embarqué quand le
/// chemin n'a pas de schéma `http(s)`, image réseau sinon, avec un repli
/// visuel en cas d'erreur.
Future<void> showImageViewer(
  BuildContext context, {
  required List<String> urls,
  int initialIndex = 0,
}) {
  if (urls.isEmpty) {
    // Défensif : jamais appelé sans image par la carte, mais un appel
    // mal outillé ne doit pas ouvrir une visionneuse vide.
    return Future.value();
  }
  return showDialog<void>(
    useSafeArea: false,
    barrierColor: Colors.black,
    context: context,
    builder: (dialogContext) => _ImageViewerPage(
      urls: urls,
      initialIndex: initialIndex.clamp(0, urls.length - 1),
    ),
  );
}

class _ImageViewerPage extends StatefulWidget {
  const _ImageViewerPage({required this.urls, required this.initialIndex});

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.urls.length;
    return Material(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Toolbar(title: '${_index + 1} / $total'),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: total,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) => InteractiveViewer(
                  panEnabled: false,
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: PostImage(
                      url: widget.urls[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La feuille est affichée à la demande : chaque image est rendue par
/// [PostImage] (Zoom et panoramique assurés par l'[InteractiveViewer]
/// ; `BoxFit.contain` pour que l'image reste entièrement visible).
///
/// Barre supérieure : compteur de position + bouton de fermeture.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const Spacer(),
        // La visionneuse doit rester fermable d'une seule façon claire :
        // le bouton croix, en plus du geste système de retour.
        IconButton(
          tooltip: 'Fermer',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
        ),
      ],
    );
  }
}
