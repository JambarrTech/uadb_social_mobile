import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedFiliere = 'Sélectionnez votre filière';
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const List<String> _filieres = [
    'Sélectionnez votre filière',
    'Informatique',
    'Mathématiques',
    'Physique-Chimie',
    'SVT',
    'Anglais',
    'Économie',
    'Droit',
    'Sociologie',
    'Agronomie',
    'Génie Civil',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTitleSection(),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Créer mon compte',
                onPressed: _acceptedTerms ? _handleRegister : null,
                height: 48,
                borderRadius: 12,
              ),
              const SizedBox(height: 24),
              _buildLoginLink(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textDark),
          ),
        ),
        const Spacer(),
        Text('UADB Social', style: AppTextStyles.headerTitle),
        const Spacer(),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Créer votre compte', style: AppTextStyles.registerTitle),
        const SizedBox(height: 8),
        Text(
          'Rejoignez le réseau social universitaire de l\'UADB',
          style: AppTextStyles.registerSubtitle,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Prénom',
                  hint: 'Ex. Matar',
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Nom',
                  hint: 'Ex. Mbow',
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            hint: 'matarmbow@gmail.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v?.isEmpty ?? true ? 'Requis' : (v!.contains('@') ? null : 'Email invalide'),
          ),
          const SizedBox(height: 16),
          DropdownField<String>(
            label: 'Filière / Département',
            hint: 'Sélectionnez votre filière',
            value: _selectedFiliere,
            items: _filieres
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _selectedFiliere = v ?? _filieres[0]),
            validator: (v) => v == _filieres[0] ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Mot de passe',
            hint: '••••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v?.isEmpty ?? true ? 'Requis' : (v!.length < 6 ? 'Min 6 caractères' : null),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirmer le mot de passe',
            hint: '••••••••••',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            validator: (v) =>
                v != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
            onEditingComplete: _handleRegister,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: 'J\'accepte les '),
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: const TextStyle(
                      color: AppColors.linkBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: const TextStyle(
                      color: AppColors.linkBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' de l\'UADB'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.linkTextMuted,
          children: [
            const TextSpan(text: 'Déjà inscrit ? '),
            TextSpan(
              text: 'Se connecter',
              style: AppTextStyles.linkText,
              recognizer: TapGestureRecognizer()..onTap = () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement registration logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie !')),
      );
      context.go('/login');
    }
  }
}