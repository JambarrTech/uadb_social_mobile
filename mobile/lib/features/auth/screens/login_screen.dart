import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/demo_notice.dart';
import '../../../shared/widgets/inline_error_banner.dart';
import '../../../shared/widgets/responsive.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // En mode démonstration (AUTH_BYPASS), aucune validation ne bloque : le
    // formulaire est envoyé tel quel.
    if (!AppConfig.authBypass &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    // La redirection est assurée par le `redirect` du routeur dès que le
    // statut passe à `authenticated` : inutile de naviguer ici.
    if (success) _passwordController.clear();
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
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _LoginHeader(),
                const SizedBox(height: 28),
                if (auth.errorMessage != null) ...[
                  InlineErrorBanner(message: auth.errorMessage!),
                ],
                _EmailField(controller: _emailController),
                const SizedBox(height: 16),
                _PasswordField(
                  controller: _passwordController,
                  enabled: !busy,
                  onSubmit: busy ? null : _handleLogin,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: busy
                        ? null
                        : () => context.pushNamed('forgot-password'),
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Se connecter',
                  // Pleine largeur explicite (le thème ne force plus la
                  // largeur minimale, voir `app_theme.dart`).
                  width: double.infinity,
                  isLoading: busy,
                  onPressed: busy ? null : _handleLogin,
                  height: 52,
                ),
                const SizedBox(height: 28),
                const _OrDivider(),
                const SizedBox(height: 28),
                const _GoogleSignInButton(),
                const SizedBox(height: 28),
                _SwitchToRegister(busy: busy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bienvenue 👋',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Connectez-vous à votre espace UADB Social',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return FormFieldBox(
      height: 54,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        autofillHints: const [AutofillHints.email],
        decoration: _inputDecoration('Adresse e-mail'),
        // En mode démonstration, le champ accepte n'importe quelle saisie : la
        // validation ne sert qu'au mode strict.
        validator: AppConfig.authBypass
            ? null
            : (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return 'Veuillez saisir votre adresse e-mail.';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Veuillez saisir une adresse e-mail valide.';
                }
                return null;
              },
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return FormFieldBox(
      height: 54,
      child: TextFormField(
        controller: controller,
        obscureText: true,
        enabled: enabled,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        decoration: _inputDecoration('Mot de passe'),
        onFieldSubmitted: (_) => onSubmit?.call(),
        validator: AppConfig.authBypass
            ? null
            : (value) => (value == null || value.isEmpty)
                  ? 'Veuillez saisir votre mot de passe.'
                  : null,
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  border: _roundedBorder(),
  enabledBorder: _roundedBorder(),
  focusedBorder: _roundedBorder(focused: true),
);

OutlineInputBorder _roundedBorder({
  bool focused = false,
  bool isError = false,
}) {
  final color = isError
      ? Colors.redAccent
      : (focused ? AppColors.primaryBlue : Colors.transparent);
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: focused || isError ? 1.5 : 1),
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OU', style: Theme.of(context).textTheme.labelMedium),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// La connexion Google n'est pas encore branchée : le bouton affiche une
/// explication explicite plutôt que de ne rien faire au toucher.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Continuer avec mon compte gmail',
      isOutlined: true,
      backgroundColor: AppColors.green,
      textColor: AppColors.green,
      borderRadius: 12,
      height: 52,
      icon: Image.asset('assets/icons/google.png', width: 18, height: 18),
      onPressed: () => showAppSnackBar(
        context,
        'La connexion avec Google arrive bientôt.',
        isError: true,
      ),
    );
  }
}

class _SwitchToRegister extends StatelessWidget {
  const _SwitchToRegister({required this.busy});

  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Pas encore de compte ?'),
        TextButton(
          onPressed: busy ? null : () => context.goNamed('register'),
          child: const Text(
            "S'inscrire",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
