import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildWelcomeSection(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 24),
              _buildFooterLinks(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UADB',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                height: 1,
              ),
            ),
            Text(
              'SOCIAL',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
                letterSpacing: 1.5,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bienvenue 👋', style: AppTextStyles.loginWelcome),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous à votre espace UADB Social',
          style: AppTextStyles.loginSubtitle,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Adresse e-mail',
            hint: 'prenom.nom@uadb.edu.sn',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v?.isEmpty ?? true ? 'Requis' : (v!.contains('@') ? null : 'Email invalide'),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
            onEditingComplete: _handleLogin,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: Text('Mot de passe oublié ?', style: AppTextStyles.linkText),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Se connecter',
            onPressed: _handleLogin,
            width: 342,
            height: 54,
            borderRadius: 12,
          ),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Continuer avec mon compte Gmail',
            onPressed: () {},
            backgroundColor: Colors.white,
            textColor: AppColors.green,
            width: 342,
            height: 54,
            borderRadius: 12,
            isOutlined: true,
            borderColor: AppColors.borderSeparator,
            icon: Image.asset(
              'assets/icons/google.png',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20),
            ),
          ),
          const SizedBox(height: 24),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderSeparator, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OU', style: AppTextStyles.fieldLabel.copyWith(fontSize: 12)),
        ),
        const Expanded(child: Divider(color: AppColors.borderSeparator, thickness: 1)),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Center(
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.linkTextMuted,
          children: [
            const TextSpan(text: 'Pas encore de compte ? '),
            TextSpan(
              text: 'S\'inscrire',
              style: AppTextStyles.linkText,
              recognizer: TapGestureRecognizer()..onTap = () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.linkTextMuted,
          children: [
            const TextSpan(text: 'Pas encore de compte ? '),
            TextSpan(
              text: 'S\'inscrire',
              style: AppTextStyles.linkText,
              recognizer: TapGestureRecognizer()..onTap = () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement login logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie !')),
      );
      context.go('/home');
    }
  }
}