import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/demo_notice.dart';
import '../../../shared/widgets/responsive.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/state/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez saisir à nouveau vos identifiants pour accéder à votre '
          'espace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.orangeRed),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;

    // Sans session obligatoire, plus rien ne redirige tout seul : on amène
    // explicitement vers l'écran de connexion, qui reste accessible.
    if (AppConfig.requireAuth) {
      context.goNamed('login');
    } else {
      showAppSnackBar(context, 'Vous êtes déconnecté.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AppPage(
            scrollable: false,
            maxWidth: ContentWidth.card,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ProfileHeader(
                  displayName: user.fullName,
                  handle: user.handle,
                  department: user.department,
                  avatarUrl: user.avatarUrl,
                  initials: user.initials,
                ),
                const SizedBox(height: 12),
                const _StatsRow(),
                const SizedBox(height: 16),
                _MenuList(
                  onLogout: () => _confirmLogout(context, ref),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.handle,
    required this.department,
    required this.avatarUrl,
    required this.initials,
  });

  final String displayName;
  final String handle;
  final String? department;
  final String? avatarUrl;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          UserAvatar(imageUrl: avatarUrl, initials: initials, radius: 48),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.postAuthorName.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            handle,
            style: AppTextStyles.postTime.copyWith(fontSize: 13),
          ),
          if (department != null) ...[
            const SizedBox(height: 4),
            Text(
              department!,
              textAlign: TextAlign.center,
              style: AppTextStyles.postAuthorRole.copyWith(fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => showAppSnackBar(
              context,
              'L’édition du profil arrive bientôt.',
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Modifier le profil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistiques de profil.
///
/// Le backend n'expose pas encore d'endpoint de statistiques : les valeurs
/// sont marquées comme indisponibles plutôt que d'afficher de faux chiffres.
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(label: 'Publications'),
          _VerticalDivider(),
          _StatColumn(label: 'Abonnés'),
          _VerticalDivider(),
          _StatColumn(label: 'Abonnements'),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('—', style: TextStyle(fontSize: 20, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.postAuthorRole.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.borderSeparator);
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final entries = <({IconData icon, String title, String subtitle})>[
      (
        icon: Icons.person_outline_rounded,
        title: 'Mon profil',
        subtitle: 'Informations personnelles',
      ),
      (
        icon: Icons.bookmark_outline_rounded,
        title: 'Mes favoris',
        subtitle: 'Publications sauvegardées',
      ),
      (
        icon: Icons.group_outlined,
        title: 'Mes communautés',
        subtitle: 'Groupes rejoints',
      ),
      (
        icon: Icons.event_outlined,
        title: 'Mes événements',
        subtitle: 'Événements à venir',
      ),
      (
        icon: Icons.settings_outlined,
        title: 'Paramètres',
        subtitle: 'Confidentialité, notifications',
      ),
      (
        icon: Icons.help_outline_rounded,
        title: 'Aide & Support',
        subtitle: 'FAQ, contact',
      ),
    ];

    return Column(
      children: [
        for (final entry in entries)
          _MenuItem(
            icon: entry.icon,
            title: entry.title,
            subtitle: entry.subtitle,
            onTap: () => showAppSnackBar(context, '${entry.title} : bientôt disponible.'),
          ),
        _MenuItem(
          icon: Icons.logout_rounded,
          title: 'Déconnexion',
          subtitle: 'Se déconnecter',
          isDestructive: true,
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.orangeRed : AppColors.primaryBlue;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.postAuthorName.copyWith(
                        fontSize: 14,
                        color: isDestructive ? AppColors.orangeRed : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.postAuthorRole.copyWith(fontSize: 11),
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
}
