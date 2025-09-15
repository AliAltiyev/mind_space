import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_design.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _parallaxController;
  late AnimationController _fadeController;
  late AnimationController _buttonController;

  late Animation<double> _parallaxAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonAnimation;

  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Добро пожаловать в MindSpace',
      subtitle: 'Ваш персональный дневник настроения с ИИ-анализом',
      lottieAsset: 'assets/animations/welcome.json',
      parallaxOffset: 0.0,
    ),
    OnboardingPage(
      title: 'Отслеживайте настроение',
      subtitle: 'Записывайте свои эмоции одним тапом и получайте инсайты',
      lottieAsset: 'assets/animations/mood_tracking.json',
      parallaxOffset: 0.2,
    ),
    OnboardingPage(
      title: 'Анализируйте паттерны',
      subtitle: 'ИИ поможет понять, что влияет на ваше настроение',
      lottieAsset: 'assets/animations/analytics.json',
      parallaxOffset: 0.4,
    ),
    OnboardingPage(
      title: 'Заботьтесь о себе',
      subtitle:
          'Получайте персональные рекомендации для улучшения самочувствия',
      lottieAsset: 'assets/animations/self_care.json',
      parallaxOffset: 0.6,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _parallaxController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _buttonController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _parallaxController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            // Параллакс фон
            _buildParallaxBackground(),

            // Основной контент
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index], index);
              },
            ),

            // Индикаторы
            _buildPageIndicators(),

            // Кнопки навигации
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return AnimatedBuilder(
      animation: _parallaxAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Слой 1 - далекие элементы
            Transform.translate(
              offset: Offset(0, -50 * _parallaxAnimation.value),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppDesign.accentColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Слой 2 - средние элементы
            Transform.translate(
              offset: Offset(0, -30 * _parallaxAnimation.value),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.0,
                    colors: [
                      AppDesign.accentColorBright.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Слой 3 - ближние элементы
            Transform.translate(
              offset: Offset(0, -20 * _parallaxAnimation.value),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomLeft,
                    radius: 1.0,
                    colors: [
                      AppDesign.accentColor.withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDesign.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie анимация
            Expanded(flex: 3, child: _buildLottieAnimation(page.lottieAsset)),

            const SizedBox(height: AppDesign.paddingXLarge),

            // Текст
            Expanded(flex: 2, child: _buildTextContent(page)),
          ],
        ),
      ),
    );
  }

  Widget _buildLottieAnimation(String asset) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        boxShadow: AppShadows.glass,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppDesign.surfaceColor,
              borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Lottie.asset(
                asset,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.psychology,
                    size: 100,
                    color: AppDesign.accentColor,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(OnboardingPage page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          page.title,
          style: AppTextStyles.headline1,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDesign.paddingMedium),

        Text(
          page.subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppDesign.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPageIndicators() {
    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => _buildIndicator(index),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: AppAnimations.fast,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? AppDesign.accentColor
            : AppDesign.accentColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      bottom: 100,
      left: AppDesign.paddingLarge,
      right: AppDesign.paddingLarge,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка "Пропустить"
          if (_currentPage < _pages.length - 1)
            GlassButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Пропустить',
                style: AppTextStyles.button.copyWith(
                  color: AppDesign.textSecondary,
                ),
              ),
            )
          else
            const SizedBox(width: 100),

          // Кнопка "Далее" / "Начать"
          AnimatedBuilder(
            animation: _buttonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 + 0.1 * _buttonAnimation.value,
                child: GlassButton(
                  onPressed: _nextPage,
                  backgroundColor: AppDesign.accentColor,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
                    style: AppTextStyles.button.copyWith(
                      color: AppDesign.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.medium,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppAnimations.slow,
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final double parallaxOffset;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.parallaxOffset,
  });
}
