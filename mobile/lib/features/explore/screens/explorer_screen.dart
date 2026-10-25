import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/responsive.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../feed/state/feed_controller.dart';
import '../../feed/state/saved_posts_controller.dart';

/// Filtres de la rangée de pastilles, alignés sur la maquette.
enum _ExploreFilter {
  tout('Tout'),
  personnes('Personnes'),
  publications('Publications'),
  communautes('Communautés'),
  evenements('Événements');

  const _ExploreFilter(this.label);

  final String label;
}

/// Compte suggéré : données de démonstration locales jusqu'à ce que le
/// backend expose l'annuaire de l'UADB.
class _ExplorePerson {
  const _ExplorePerson(this.name);

  final String name;
}

/// Communauté de démonstration.
class _ExploreCommunity {
  const _ExploreCommunity(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

/// Événement de démonstration (badge de date + description).
class _ExploreEvent {
  const _ExploreEvent(this.day, this.title, this.meta);

  final String day;
  final String title;
  final String meta;
}

const List<_ExplorePerson> _people = [
  _ExplorePerson('Brahima Fall'),
  _ExplorePerson('Aminata Diagne'),
  _ExplorePerson('Dr. Cheikh Mbaye'),
  _ExplorePerson('Fatou Sarr'),
];

const List<_ExploreCommunity> _communities = [
  _ExploreCommunity(
    'Club Informatique UADB',
    'Initiatives et projets étudiants',
  ),
  _ExploreCommunity(
    'Community des UFA de Bambey',
    'Apprenants des UFA de Bambey',
  ),
  _ExploreCommunity('English Club Bambey', 'Pratique libre de l’anglais'),
];

const List<_ExploreEvent> _events = [
  _ExploreEvent(
    '15',
    'Journées Portes Ouvertes UADB 2025',
    'Campus de Bambey · Tout public',
  ),
  _ExploreEvent(
    '15',
    'Hackathon IA 2025 · Agriculture',
    'Salles TS2 · Sur inscription',
  ),
];

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ExploreFilter _filter = _ExploreFilter.tout;
  String _query = '';

  /// Suivis / adhésions : état local de démonstration (aucun appel
  /// serveur), remis à zéro par l'API dès qu'elle existera.
  final Set<String> _followedIds = <String>{};
  final Set<String> _joinedIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ExplorePerson> _matchingPeople() {
    if (_query.isEmpty) return _people;
    return _people
        .where((person) => person.name.toLowerCase().contains(_query))
        .toList();
  }

  List<_ExploreCommunity> _matchingCommunities() {
    if (_query.isEmpty) return _communities;
    return _communities
        .where(
          (community) =>
              community.title.toLowerCase().contains(_query) ||
              community.subtitle.toLowerCase().contains(_query),
        )
        .toList();
  }

  List<_ExploreEvent> _matchingEvents() {
    if (_query.isEmpty) return _events;
    return _events
        .where(
          (event) =>
              event.title.toLowerCase().contains(_query) ||
              event.meta.toLowerCase().contains(_query),
        )
        .toList();
  }

  void _onSearchChanged(String value) =>
      setState(() => _query = value.trim().toLowerCase());

  /// Publications du fil correspondant à la requête.
  ///
  /// La recherche porte sur les données réelles du fil ([feedProvider]) : le
  /// contenu de démonstration comme les publications créées dans l'app sont
  /// traités exactement pareil, sans code spécifique de l'un ou de l'autre.
  List<Post> _matchingPosts(List<Post> posts) {
    if (_query.isEmpty) return posts;
    return posts
        .where(
          (post) =>
              post.content.toLowerCase().contains(_query) ||
              post.authorName.toLowerCase().contains(_query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(feedProvider);
    final savedIds = ref.watch(savedIdsProvider);
    final matchingPosts = _matchingPosts(posts);
    final people = _matchingPeople();
    final communities = _matchingCommunities();
    final events = _matchingEvents();

    final bool showPublications =
        _filter == _ExploreFilter.tout ||
        _filter == _ExploreFilter.publications;
    final bool showPeople =
        _filter == _ExploreFilter.tout || _filter == _ExploreFilter.personnes;
    final bool showCommunities =
        _filter == _ExploreFilter.tout || _filter == _ExploreFilter.communautes;
    final bool showEvents =
        _filter == _ExploreFilter.tout || _filter == _ExploreFilter.evenements;

    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: Column(
          children: [
            _Header(controller: _searchController, onChanged: _onSearchChanged),
            const Divider(height: 1),
            Expanded(
              child: AppPage(
                scrollable: false,
                maxWidth: ContentWidth.feed,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    _FilterChips(
                      selected: _filter,
                      onSelected: (filter) => setState(() => _filter = filter),
                    ),
                    const SizedBox(height: 20),
                    if (showPublications)
                      _PublicationsSection(
                        title: _filter == _ExploreFilter.tout
                            ? 'Publication tendance'
                            : 'Publications',
                        posts: matchingPosts,
                        // En mode « Tout », la tendance met en avant la
                        // publication la plus récente correspondant à la
                        // requête ; en mode dédié, la liste complète.
                        slice: _filter == _ExploreFilter.tout
                            ? (posts) => posts.take(1).toList()
                            : (posts) => posts,
                        savedIds: savedIds,
                        onLike: (id) =>
                            ref.read(feedProvider.notifier).toggleLike(id),
                        onShare: (id) =>
                            ref.read(feedProvider.notifier).share(id),
                        onToggleSave: (id) =>
                            ref.read(savedIdsProvider.notifier).toggle(id),
                      ),
                    if (showPublications) const SizedBox(height: 28),
                    if (showPeople)
                      _PeopleSection(
                        people: people,
                        followedIds: _followedIds,
                        onToggleFollow: (person) => setState(
                          () => _followedIds.contains(person.name)
                              ? _followedIds.remove(person.name)
                              : _followedIds.add(person.name),
                        ),
                      ),
                    if (showPeople) const SizedBox(height: 28),
                    if (showCommunities)
                      _CommunitiesSection(
                        communities: communities,
                        joinedIds: _joinedIds,
                        onToggleJoin: (community) => setState(
                          () => _joinedIds.contains(community.title)
                              ? _joinedIds.remove(community.title)
                              : _joinedIds.add(community.title),
                        ),
                      ),
                    if (showCommunities) const SizedBox(height: 28),
                    if (showEvents)
                      _EventsSection(events: events, onOpen: _openEvent),
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

  void _openEvent(_ExploreEvent event) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('« ${event.title} » : détails bientôt disponibles.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// Barre de recherche en tête d'écran (identique à la maquette).
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
            const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
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

/// Rangée de pastilles de filtrage (Tout · Personnes · Publications ·
/// Communautés · Événements), défilable horizontalement.
///
/// Construite éagèrement (une [Row] simple, jamais une ListView paresseuse) :
/// les cinq pastilles existent dans l'arbre en permanence, ce qui évite les
/// surprises de recherche de widgets dans les tests sans rien changer à
/// l'aspect — sur téléphone réel des cinq tiennent dans la largeur.
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final _ExploreFilter selected;
  final ValueChanged<_ExploreFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _ExploreFilter.values) ...[
            _FilterChip(
              filter: filter,
              selected: filter == selected,
              onSelected: () => onSelected(filter),
            ),
            if (filter != _ExploreFilter.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.selected,
    required this.onSelected,
  });

  final _ExploreFilter filter;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryBlue : Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onSelected,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : AppColors.borderSeparator,
            ),
          ),
          child: Text(
            filter.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Section « Publication(s) » : les cartes du fil, réutilisées telles quelles.
class _PublicationsSection extends StatelessWidget {
  const _PublicationsSection({
    required this.title,
    required this.posts,
    required this.slice,
    required this.savedIds,
    required this.onLike,
    required this.onShare,
    required this.onToggleSave,
  });

  final String title;
  final List<Post> posts;

  /// Réduit la liste selon le filtre actif (un seul résultat en mode
  /// « Tout », liste complète en mode « Publications »).
  final List<Post> Function(List<Post> posts) slice;

  final Set<String> savedIds;
  final ValueChanged<String> onLike;
  final ValueChanged<String> onShare;
  final ValueChanged<String> onToggleSave;

  @override
  Widget build(BuildContext context) {
    final visible = slice(posts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.explorerSectionTitle),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          const Text(
            'Aucun résultat : aucune publication ne correspond à la '
            'recherche.',
            style: AppTextStyles.createPostHint,
          )
        else
          for (final post in visible) ...[
            PostCard(
              post: post,
              onLike: () => onLike(post.id),
              onShare: () => onShare(post.id),
              isSaved: savedIds.contains(post.id),
              onToggleSave: () => onToggleSave(post.id),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

/// Section « Personnes suggérées » : cartes défilables horizontalement,
/// avec bouton « Suivre » à deux états (local, sans serveur).
class _PeopleSection extends StatelessWidget {
  const _PeopleSection({
    required this.people,
    required this.followedIds,
    required this.onToggleFollow,
  });

  final List<_ExplorePerson> people;
  final Set<String> followedIds;
  final ValueChanged<_ExplorePerson> onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personnes suggérées',
          style: AppTextStyles.explorerSectionTitle,
        ),
        const SizedBox(height: 12),
        if (people.isEmpty)
          const Text(
            'Aucun résultat : aucune personne ne correspond à la recherche.',
            style: AppTextStyles.createPostHint,
          )
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: people.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _PersonCard(
                person: people[index],
                followedIds: followedIds,
                onToggle: () => onToggleFollow(people[index]),
              ),
            ),
          ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.followedIds,
    required this.onToggle,
  });

  final _ExplorePerson person;
  final Set<String> followedIds;
  final VoidCallback onToggle;

  bool get _isFollowed => followedIds.contains(person.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Column(
        children: [
          // Avatar des initiales du nom : aucune photo locale à executer,
          // la palette de l'initiale vient du hash (voir [UserAvatar]).
          UserAvatar(initials: _initials(person.name), radius: 22),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                person.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                backgroundColor: _isFollowed
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : AppColors.primaryBlue,
                foregroundColor: _isFollowed
                    ? AppColors.primaryBlue
                    : Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isFollowed ? 'Suivi' : 'Suivre',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final words = name
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Section « Communautés populaires » : tuiles larges avec adhésion
/// locale à deux états.
class _CommunitiesSection extends StatelessWidget {
  const _CommunitiesSection({
    required this.communities,
    required this.joinedIds,
    required this.onToggleJoin,
  });

  final List<_ExploreCommunity> communities;
  final Set<String> joinedIds;
  final ValueChanged<_ExploreCommunity> onToggleJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Communautés populaires',
          style: AppTextStyles.explorerSectionTitle,
        ),
        const SizedBox(height: 12),
        if (communities.isEmpty)
          const Text(
            'Aucun résultat : aucune communauté ne correspond à la recherche.',
            style: AppTextStyles.createPostHint,
          )
        else
          for (final community in communities) ...[
            _CommunityTile(
              community: community,
              joined: joinedIds.contains(community.title),
              onToggle: () => onToggleJoin(community),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.community,
    required this.joined,
    required this.onToggle,
  });

  final _ExploreCommunity community;
  final bool joined;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSeparator),
          ),
          child: Row(
            children: [
              UserAvatar(initials: _initials(community.title), radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.explorerCardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      community.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.explorerCardSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 30,
                child: TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    backgroundColor: joined
                        ? Colors.transparent
                        : AppColors.primaryBlue.withValues(alpha: 0.12),
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: joined
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    joined ? 'Membre' : 'Rejoindre',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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

/// Section « Événements à venir » : badge de date + description + chevron.
class _EventsSection extends StatelessWidget {
  const _EventsSection({required this.events, required this.onOpen});

  final List<_ExploreEvent> events;
  final ValueChanged<_ExploreEvent> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Événements à venir',
          style: AppTextStyles.explorerSectionTitle,
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const Text(
            'Aucun résultat : aucun événement ne correspond à la recherche.',
            style: AppTextStyles.createPostHint,
          )
        else
          for (final event in events) ...[
            _EventTile(event: event, onOpen: () => onOpen(event)),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onOpen});

  final _ExploreEvent event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSeparator),
          ),
          child: Row(
            children: [
              // Badge de date de la maquette : chiffre du jour sur fond
              // de la couleur principale.
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  event.day,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.explorerCardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.explorerCardSubtitle,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
