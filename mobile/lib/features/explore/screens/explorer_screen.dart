import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/user_avatar.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  int _currentNavIndex = 1;
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = ['Tout', 'Personnes', 'Publications', 'Communautés', 'Événements'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 2) {
      context.go('/create-post');
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrendingPosts(),
                    const SizedBox(height: 24),
                    _buildSuggestedPeople(),
                    const SizedBox(height: 24),
                    _buildPopularCommunities(),
                    const SizedBox(height: 24),
                    _buildUpcomingEvents(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        messagesBadgeCount: 3,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSeparator),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher sur UADB Social...',
            hintStyle: AppTextStyles.fieldPlaceholder.copyWith(fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = _selectedFilter == index;
          return FilterChip(
            label: Text(
              _filters[index],
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textMedium,
              ),
            ),
            selected: isActive,
            onSelected: (_) => setState(() => _selectedFilter = index),
            backgroundColor: Colors.transparent,
            selectedColor: isActive && index == 1 ? AppColors.explorerActive : AppColors.primaryBlue,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isActive ? Colors.transparent : AppColors.borderSeparator,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  Widget _buildTrendingPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publications tendance', style: AppTextStyles.explorerSectionTitle),
        const SizedBox(height: 12),
        _buildTrendingPostCard(
          author: 'Aminata Diallo',
          time: '· 10h ago',
          content:
              'Super enthousiaste pour le hackathon UADB ce week-end ! Qui d\'autre participe ?',
          likes: 24,
          comments: 8,
        ),
        const SizedBox(height: 12),
        _buildTrendingPostCard(
          author: 'Moussa Ndiaye',
          time: '· 2j ago',
          content:
              'Journée terrain à Nianing avec la promo M1 Agronomie. Expérience enrichissante !',
          likes: 45,
          comments: 3,
        ),
      ],
    );
  }

  Widget _buildTrendingPostCard({
    required String author,
    required String time,
    required String content,
    required int likes,
    required int comments,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(author, style: AppTextStyles.explorerCardTitle),
              const SizedBox(width: 8),
              Text(time, style: AppTextStyles.explorerCardSubtitle),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.explorerCardContent, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('$likes', style: AppTextStyles.interactionCount.copyWith(fontSize: 10)),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('$comments', style: AppTextStyles.interactionCount.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPeople() {
    final people = <Map<String, String?>>[
      {'name': 'Ibrahima Fall', 'role': 'M2 Informatique', 'avatar': null},
      {'name': 'Aïssatou Bâ', 'role': 'L2 Anglais', 'avatar': null},
      {'name': 'Dr. Cheikh Mbaye', 'role': 'Enseignant Maths', 'avatar': null},
      {'name': 'Mariama Diallo', 'role': 'L1 Économie', 'avatar': null},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personnes suggérées', style: AppTextStyles.explorerSectionTitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final person = people[index];
              return _buildSuggestedPersonCard(
                name: person['name']!,
                role: person['role']!,
                avatarUrl: person['avatar'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedPersonCard({
    required String name,
    required String role,
    String? avatarUrl,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Column(
        children: [
          UserAvatar(initials: _getInitials(name), radius: 36, imageUrl: avatarUrl),
          const SizedBox(height: 10),
          Text(name, style: AppTextStyles.suggestedPersonName, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(role, style: AppTextStyles.suggestedPersonRole, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.followGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text('Suivre', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCommunities() {
    final communities = [
      {'name': 'Club Informatique UADB', 'desc': 'Programmation, IA, Dev Web', 'members': '234 membres', 'icon': Icons.computer_rounded},
      {'name': 'BDE UADB', 'desc': 'Bureau des Étudiants - Vie étudiante', 'members': '1.2k membres', 'icon': Icons.people_rounded},
      {'name': 'English Club Bambey', 'desc': 'Pratique de l\'anglais, discussions', 'members': '98 membres', 'icon': Icons.translate_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Communautés populaires', style: AppTextStyles.explorerSectionTitle),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: communities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = communities[index];
            return _buildCommunityCard(
              name: c['name']!,
              description: c['desc']!,
              members: c['members']!,
              icon: c['icon'] as IconData,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommunityCard({
    required String name,
    required String description,
    required String members,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.communityName),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.communityDesc, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(members, style: AppTextStyles.communityMembers),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.joinGreen,
              side: const BorderSide(color: AppColors.joinGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Rejoindre', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 10, color: AppColors.joinGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    final events = [
      {'day': 'MAR', 'date': '15', 'title': 'Journée Portes Ouvertes UADB 2025', 'location': 'Campus principal'},
      {'day': 'JEU', 'date': '24', 'title': 'Hackathon IA & Agriculture', 'location': 'UFR SAT Lab'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Événements à venir', style: AppTextStyles.explorerSectionTitle),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final e = events[index];
            return _buildEventCard(
              day: e['day']!,
              date: e['date']!,
              title: e['title']!,
              location: e['location']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String day,
    required String date,
    required String title,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSeparator),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.eventDateBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: AppTextStyles.eventDay),
                const SizedBox(height: 2),
                Text(date, style: AppTextStyles.eventDate),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.eventTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location, style: AppTextStyles.eventLocation, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}