import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/inline_error_banner.dart';
import '../../../shared/widgets/responsive.dart';
import '../state/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email: _emailController.text);

    if (!mounted || !ok) return;
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: AppPage(
          maxWidth: ContentWidth.form,
          alignment: _sent ? Alignment.center : Alignment.topCenter,
          child: _sent
              ? _Confirmation(email: _emailController.text.trim())
              : _buildForm(auth.errorMessage, busy),
        ),
      ),
    );
  }

  Widget _buildForm(String? errorMessage, bool busy) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Retour',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mot de passe oublié ?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saisissez l’adresse e-mail associée à votre compte UADB. '
            'Nous vous enverrons un lien de réinitialisation.',
          ),
          const SizedBox(height: 32),
          if (errorMessage != null) ...[
            InlineErrorBanner(message: errorMessage),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Adresse e-mail',
              hintText: 'matarmbow@uadb.edu.sn',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
            onFieldSubmitted: (_) => busy ? null : _handleSubmit(),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Veuillez saisir votre adresse e-mail.';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Adresse e-mail invalide.';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'Envoyer le lien',
            // Pleine largeur explicite : le thème ne mentionne plus
            // `minimumSize` en largeur (voir `app_theme.dart`).
            width: double.infinity,
            isLoading: busy,
            onPressed: busy ? null : _handleSubmit,
            height: 52,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => context.goNamed('login'),
              child: const Text('Retour à la connexion'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Vérifiez votre boîte mail',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Si un compte est associé à $email, un lien de réinitialisation '
          'vient d’être envoyé.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Retour à la connexion',
          // Pleine largeur explicite (le thème ne force plus la largeur).
          width: double.infinity,
          onPressed: () => context.goNamed('login'),
          height: 50,
        ),
      ],
    );
  }
}
