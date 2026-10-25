import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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
                  child: Center(child: _Image(url: widget.urls[index])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

/// Image en plein écran, adaptée au ratio de l'écran.
///
/// `BoxFit.contain` : l'image est entièrement visible, sans rognage, la
/// visionneuse servant à l'inspecter et non à l'enchâsser dans la carte.
/// Zoom et panoramique sont assurés par l'[InteractiveViewer] parent.
class _Image extends StatelessWidget {
  const _Image({required this.url});

  final String url;

  static bool _isAssetPath(String url) =>
      !url.startsWith('http://') && !url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return _isAssetPath(url)
        ? Image.asset(url, fit: BoxFit.contain)
        : Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _LoadingPlaceholder(),
            errorBuilder: (context, error, stackTrace) =>
                const _ErrorPlaceholder(),
          );
  }
}

/// Chargement en cours, discret sur fond noir.
class _LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

/// Repli quand l'image est inaccessible : la mise en page reste intacte.
class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white38,
          size: 48,
        ),
        SizedBox(height: 12),
        Text(
          'Image indisponible',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}
