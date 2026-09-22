import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPageData {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isLastPage;

  const _OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.isLastPage = false,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      imagePath: 'assets/onboarding/students_laptops.png',
      title: 'Votre communauté\nuniversitaire,\ntoujours avec vous.',
      subtitle:
          'Échangez avec les étudiants, enseignants, associations et communautés de l\'UADB.',
      buttonText: 'Commencer',
    ),
    _OnboardingPageData(
      imagePath: 'assets/onboarding/phone_mockup.png',
      title: 'Suivez la vie du campus',
      subtitle:
          'Retrouvez les actualités, événements, groupes et conversations qui comptent pour vous.',
      buttonText: 'Continuer',
    ),
    _OnboardingPageData(
      imagePath: 'assets/onboarding/network_illustration.png',
      title: 'Construisez votre réseau',
      subtitle:
          'Partagez vos idées, rejoignez des communautés et créez des liens utiles.',
      buttonText: 'Créer un compte',
      isLastPage: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAuth,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPage(
                    page: page,
                    onNext: _nextPage,
                    showDots: index == 1 || index == 2,
                    currentIndex: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData page;
  final VoidCallback onNext;
  final bool showDots;
  final int currentIndex;

  const _OnboardingPage({
    required this.page,
    required this.onNext,
    this.showDots = false,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            flex: 3,
            child: Image.asset(
              page.imagePath,
              width: double.infinity,
              height: 295,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 295,
                decoration: BoxDecoration(
                  color: AppColors.borderSeparator,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: page.title.contains('\n')
                ? AppTextStyles.onboardingTitle
                : AppTextStyles.onboardingTitleLarge,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          Text(
            page.subtitle,
            style: AppTextStyles.onboardingSubtitle,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 40),
          if (showDots) _buildPageDots(),
          const SizedBox(height: 24),
          CustomButton(
            text: page.buttonText,
            onPressed: onNext,
            width: 342,
            height: 52,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}