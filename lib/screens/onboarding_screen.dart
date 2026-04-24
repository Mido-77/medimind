import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      emoji: '💊',
      gradient: AppColors.primaryGradient,
      title: 'Never Miss a Dose',
      subtitle:
          'Set reminders for all your medicines and stay on top of your health routine effortlessly.',
    ),
    _OnboardPage(
      emoji: '📊',
      gradient: AppColors.tealGradient,
      title: 'Track Your Progress',
      subtitle:
          'Visualize your adherence with beautiful charts and streaks that keep you motivated.',
    ),
    _OnboardPage(
      emoji: '🏥',
      gradient: AppColors.pinkGradient,
      title: 'Your Health, Simplified',
      subtitle:
          'Manage multiple medicines, schedules, and history — all in one beautiful app.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await AppStateScope.of(context).setOnboardingDone();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage < _pages.length - 1
                          ? TextButton(
                              onPressed: _finish,
                              child: Text(
                                'Skip',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withAlpha(204),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox(width: 60),
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _currentPage ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _currentPage
                                  ? Colors.white
                                  : Colors.white.withAlpha(102),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 48),
                  child: GestureDetector(
                    onTap: _next,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? 'Continue →'
                              : 'Get Started',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final LinearGradient gradient;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.emoji,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;

  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                    color: Colors.white.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(page.emoji,
                      style: const TextStyle(fontSize: 72)),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withAlpha(217),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}
