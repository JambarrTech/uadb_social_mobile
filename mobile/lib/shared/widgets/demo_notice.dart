import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'custom_button.dart';

/// Bandeau signalant qu'un contenu est une démonstration, pas une donnée réelle.
///
/// L'application n'appelle aucun serveur : sans cet avertissement, des
/// publications de démonstration pourraient être prises pour le fil réel.
class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Affiche un message éphémère. Utilisable partout sans construire un
/// `ScaffoldMessenger` à la main.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.orangeRed : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
}

/// Bouton d'action réutilisé par les écrans vides.
class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => CustomButton(
    text: label,
    width: 180,
    height: 44,
    borderRadius: 22,
    onPressed: onPressed,
  );
}
