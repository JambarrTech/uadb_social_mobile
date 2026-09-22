import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildInfoIcon(),
              const SizedBox(height: 32),
              Text('Mot de passe oublié ?', style: AppTextStyles.forgotPasswordTitle, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                'Entrez votre adresse e-mail pour recevoir\nun lien de réinitialisation.',
                style: AppTextStyles.forgotPasswordSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: CustomTextField(
                  label: 'Adresse e-mail',
                  hint: 'prenom.nom@uadb.edu.sn',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Requis' : (v!.contains('@') ? null : 'Email invalide'),
                  onEditingComplete: _handleSend,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Envoyer le lien',
                onPressed: _handleSend,
                width: 200,
                height: 48,
                borderRadius: 24,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Retour à la connexion',
                  style: AppTextStyles.linkText.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.help_outline_rounded, size: 40, color: AppColors.primaryBlue),
    );
  }

  void _handleSend() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien de réinitialisation envoyé !')),
      );
      context.go('/login');
    }
  }
}