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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const String _departmentPlaceholder = 'Sélectionnez votre filière';

  static const List<String> _departments = [
    _departmentPlaceholder,
    'Informatique',
    'Mathématiques',
    'Sciences économiques',
    'Droit',
    'Sociologie',
    'Agronomie',
    'Génie civil',
  ];

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedDepartment = _departmentPlaceholder;
  bool _acceptedTerms = false;
  bool _showLocalError = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // En mode démonstration, aucune validation ni condition d'utilisation ne
    // bloque : le formulaire part tel quel.
    if (!AppConfig.authBypass) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      if (!_acceptedTerms) {
        setState(() => _showLocalError = true);
        return;
      }
    }
    setState(() => _showLocalError = false);
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          department: _selectedDepartment,
        );

    if (!mounted) return;
    if (success) {
      showAppSnackBar(context, 'Compte créé. Bienvenue sur UADB Social !');
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Créer votre compte',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Rejoignez le réseau social universitaire de l\'UADB'),
                const SizedBox(height: 28),

                if (auth.errorMessage != null)
                  InlineErrorBanner(message: auth.errorMessage!),
                if (_showLocalError && !_acceptedTerms)
                  const InlineErrorBanner(
                    message: 'Vous devez accepter les conditions d’utilisation.',
                  ),

                _field(
                  label: 'Prénom',
                  hint: 'Ex. Matar',
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  validator: _required('Prénom'),
                ),
                _field(
                  label: 'Nom',
                  hint: 'Ex. Mbow',
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  validator: _required('Nom'),
                ),
                _field(
                  label: 'Email',
                  hint: 'matarmbow@uadb.edu.sn',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 16),
                _DepartmentDropdown(
                  value: _selectedDepartment,
                  enabled: !busy,
                  onChanged: (value) =>
                      setState(() => _selectedDepartment = value),
                ),
                _field(
                  label: 'Mot de passe',
                  hint: 'Au moins 6 caractères',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: _passwordValidator,
                ),
                _field(
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: busy ? null : _handleRegister,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Champ requis';
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _TermsCheckbox(
                  value: _acceptedTerms,
                  onChanged: (value) => setState(() {
                    _acceptedTerms = value;
                    if (value) _showLocalError = false;
                  }),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Créer mon compte',
                  isLoading: busy,
                  onPressed: busy ? null : _handleRegister,
                  backgroundColor: AppColors.green,
                  height: 50,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà inscrit ?'),
                    TextButton(
                      onPressed: busy ? null : () => context.goNamed('login'),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    VoidCallback? onEditingComplete,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(focused: true),
      ),
    ),
  );

  static String? Function(String?) _required(String field) => (value) =>
      (value == null || value.trim().isEmpty) ? 'Champ requis' : null;

  static String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Champ requis';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email invalide';
    }
    return null;
  }

  static String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Champ requis';
    if (password.length < 6) return 'Mot de passe trop court';
    return null;
  }
}

OutlineInputBorder _border({bool focused = false}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(14),
  borderSide: BorderSide(
    color: focused ? AppColors.primaryBlue : Colors.transparent,
    width: focused ? 1.5 : 1,
  ),
);

class _DepartmentDropdown extends StatelessWidget {
  const _DepartmentDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        onChanged: enabled ? (v) => v == null || v == value ? null : onChanged(v) : null,
        validator: (v) => (v == null || v == _RegisterScreenState._departmentPlaceholder)
            ? 'Champ requis'
            : null,
        decoration: InputDecoration(
          labelText: 'Filière / Département',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(focused: true),
        ),
        items: [
          for (final department in _RegisterScreenState._departments)
            DropdownMenuItem(
              value: department,
              child: Text(department, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text.rich(
        TextSpan(
          text: 'J’accepte les ',
          style: Theme.of(context).textTheme.bodySmall,
          children: const [
            TextSpan(
              text: 'conditions d’utilisation',
              style: TextStyle(
                color: AppColors.linkBlue,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(text: ' et la '),
            TextSpan(
              text: 'politique de confidentialité',
              style: TextStyle(
                color: AppColors.linkBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
