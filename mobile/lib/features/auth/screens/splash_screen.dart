import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/navigation/app_nav.dart';
import '../state/auth_controller.dart';

/// Écran de démarrage.
///
/// Affiche l'animation, puis route selon l'état réel de la session :
/// session valide → `/home`, sinon onboarding (une seule fois) puis login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _animation = Duration(milliseconds: 2200);

  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _animation,
    )..forward();
    _progressController.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Sans exigence de session, l'application s'ouvre sur l'accueil : tous
    // les écrans restent accessibles, mais on n'impose pas de s'identifier.
    if (!AppConfig.requireAuth) {
      context.go(AppRoutes.home);
      return;
    }

    final auth = ref.read(authControllerProvider);
    final onboardingSeen = ref.read(onboardingSeenProvider);

    final destination = switch (auth.status) {
      AuthStatus.authenticated => AppRoutes.home,
      AuthStatus.unknown => AppRoutes.home,
      AuthStatus.unauthenticated => onboardingSeen
          ? AppRoutes.login
          : AppRoutes.onboarding,
    };
    context.go(destination);
  }

  @override
  void dispose() {
    _progressController
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: ClipOval(
                          child: Image.asset(
                            'logo.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.school_rounded,
                                  color: Color(0xFF00449B),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Le réseau de notre communauté.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFD8E7F5),
                  ),
                ),
                const SizedBox(height: 32),
                _ProgressBar(animation: _progressController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140, minWidth: 100),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => LinearProgressIndicator(
          value: animation.value,
          minHeight: 5,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: Colors.white.withValues(alpha: 0.35),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF12912F)),
        ),
      ),
    );
  }
}
