import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_view.dart';
import '../state/messages_badge.dart';

/// Écran de messagerie.
///
/// Le backend n'expose pas encore d'endpoint de conversations : l'écran
/// affiche un état vide explicite plutôt qu'une liste de données fictives.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFeed,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Row(
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: EmptyView(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Aucune conversation',
                subtitle:
                    'Vos conversations avec les étudiants, enseignants et '
                    'communautés de l\'UADB apparaîtront ici.',
                action: TextButton.icon(
                  onPressed: () =>
                      ref.read(unreadMessagesControllerProvider.notifier).markAllRead(),
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: const Text('Tout marquer comme lu'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
