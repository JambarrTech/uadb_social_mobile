import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/responsive.dart';
import '../state/auth_controller.dart';
import '../widgets/onboarding_page.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.isLastPage = false,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isLastPage;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      imagePath: 'assets/onboarding/students_laptops.png',
      title: 'Votre communauté\nuniversitaire,\ntoujours avec vous.',
      subtitle:
          'Échangez avec les étudiants, enseignants, associations et '
          'communautés de l\'UADB.',
      buttonText: 'Commencer',
    ),
    OnboardingPageData(
      imagePath: 'assets/onboarding/phone_mockup.png',
      title: 'Suivez la vie du campus',
      subtitle:
          'Retrouvez les actualités, événements, groupes et conversations '
          'qui comptent pour vous.',
      buttonText: 'Continuer',
    ),
    OnboardingPageData(
      imagePath: 'assets/onboarding/network_illustration.png',
      title: 'Construisez votre réseau',
      subtitle:
          'Partagez vos idées, rejoignez des communautés et créez des liens '
          'utiles.',
      buttonText: 'Créer un compte',
      isLastPage: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    // Onboarding proposé une seule fois par installation.
    await ref.read(completeOnboardingProvider)();
    if (!mounted) return;
    context.goNamed('register');
  }

  Future<void> _skip() async {
    await ref.read(completeOnboardingProvider)();
    if (!mounted) return;
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: AppPage(
          scrollable: false,
          maxWidth: 560,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          verticalPadding: 8,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Passer'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPage(
                      imagePath: page.imagePath,
                      title: page.title,
                      subtitle: page.subtitle,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _PageDots(count: _pages.length, currentIndex: _currentPage),
              const SizedBox(height: 20),
              CustomButton(
                text: currentPage.buttonText,
                onPressed: _nextPage,
                width: double.infinity,
                height: 52,
                borderRadius: 14,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryBlue
                : AppColors.borderSeparator,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
