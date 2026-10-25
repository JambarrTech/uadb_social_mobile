import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/responsive.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Contenus mis en avant.
///
/// Le backend n'expose pas encore d'endpoint d'exploration : ces entrées sont
/// identifiées comme données de démonstration et la recherche filtre dessus
/// localement. Elles seront remplacées par l'API.
class ExploreEntry {
  const ExploreEntry({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const List<ExploreEntry> _trending = [
  ExploreEntry(title: 'Rentrée universitaire 2026', subtitle: '1,2 k publications'),
  ExploreEntry(title: 'Clubs et associations', subtitle: 'Rejoignez un groupe'),
  ExploreEntry(title: 'Examens et emplois', subtitle: 'Session de rattrapage'),
  ExploreEntry(title: 'Campus et bibliothèque', subtitle: 'Horaires et espaces'),
];

const List<ExploreEntry> _communities = [
  ExploreEntry(title: 'Club Tech UADB', subtitle: 'Association étudiante'),
  ExploreEntry(title: 'Littérature & Poésie', subtitle: 'Club de lecture'),
  ExploreEntry(title: 'Étudiants Internationaux', subtitle: 'Communauté'),
];

const List<ExploreEntry> _events = [
  ExploreEntry(
    title: 'Atelier Git & GitHub',
    subtitle: 'Samedi, 10h · Salle A12',
  ),
  ExploreEntry(
    title: 'Conférence entrepreneuriat',
    subtitle: 'Mardi 18h · Amphi 2',
  ),
];

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExploreEntry> _matches(List<ExploreEntry> entries) {
    if (_query.isEmpty) return entries;
    return entries
        .where(
          (entry) =>
              entry.title.toLowerCase().contains(_query) ||
              entry.subtitle.toLowerCase().contains(_query),
        )
        .toList();
  }

  void _onSearchChanged(String value) =>
      setState(() => _query = value.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            const Divider(height: 1),
            Expanded(
              child: AppPage(
                scrollable: false,
                maxWidth: ContentWidth.feed,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    const _DemoDataNotice(),
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Tendances',
                      entries: _matches(_trending),
                      emptyLabel: 'aucune tendance',
                    ),
                    const SizedBox(height: 28),
                    const _Section(
                      title: 'Personnes à suivre',
                      notice:
                          'Les suggestions de comptes seront disponibles dès '
                          'que le backend exposera l’annuaire de l’UADB.',
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'Communautés populaires',
                      entries: _matches(_communities),
                      emptyLabel: 'aucune communauté',
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'Événements à venir',
                      entries: _matches(_events),
                      emptyLabel: 'aucun événement',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundFeed,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Rechercher sur UADB Social',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoDataNotice extends StatelessWidget {
  const _DemoDataNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.orangeRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.orangeRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Contenu de démonstration : l’API d’exploration n’est pas '
              'encore disponible.',
              style: AppTextStyles.createPostHint.copyWith(
                color: AppColors.orangeRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    this.entries = const [],
    this.notice,
    this.emptyLabel = '',
  });

  final String title;
  final List<ExploreEntry> entries;
  final String? notice;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.explorerSectionTitle),
        const SizedBox(height: 12),
        if (notice != null)
          _NoticeCard(message: notice!)
        else if (entries.isEmpty)
          Text(
            'Aucun résultat : $emptyLabel.',
            style: AppTextStyles.createPostHint,
          )
        else
          for (final entry in entries) ...[
            _EntryTile(entry: entry),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_search_outlined, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: AppTextStyles.createPostHint),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final ExploreEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('« ${entry.title} » : bientôt disponible.'),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              UserAvatar(initials: _initials(entry.title), radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.explorerCardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.explorerCardSubtitle,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String title) {
    final words = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
