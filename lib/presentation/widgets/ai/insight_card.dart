import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/ai_insight.dart';
import '../core/glass_surface.dart';

/// Виджет карточки AI инсайта с анимациями
class InsightCard extends StatefulWidget {
  /// AI инсайт для отображения
  final AIInsight insight;

  /// Высота карточки
  final double height;

  /// Ширина карточки
  final double width;

  /// Колбэк при тапе на карточку
  final VoidCallback? onTap;

  /// Задержка перед началом анимации
  final Duration animationDelay;

  /// Продолжительность анимации emoji
  final Duration emojiAnimationDuration;

  /// Продолжительность печати текста
  final Duration textAnimationDuration;

  const InsightCard({
    super.key,
    required this.insight,
    this.height = 200.0,
    this.width = 300.0,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.emojiAnimationDuration = const Duration(milliseconds: 800),
    this.textAnimationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard>
    with TickerProviderStateMixin {
  late AnimationController _emojiController;
  late AnimationController _titleController;
  late AnimationController _descriptionController;
  late AnimationController _cardController;

  late Animation<double> _emojiScaleAnimation;
  late Animation<double> _emojiRotationAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _descriptionSlideAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardOpacityAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Контроллер для emoji анимации
    _emojiController = AnimationController(
      duration: widget.emojiAnimationDuration,
      vsync: this,
    );

    _emojiScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.elasticOut),
    );

    _emojiRotationAnimation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.easeOutBack),
    );

    // Контроллер для заголовка
    _titleController = AnimationController(
      duration: widget.textAnimationDuration,
      vsync: this,
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    // Контроллер для описания
    _descriptionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _descriptionSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _descriptionController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Контроллер для карточки
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    // Задержка перед началом анимации
    await Future.delayed(widget.animationDelay);

    if (!mounted) return;

    setState(() {
      _isAnimating = true;
    });

    // 1. Анимация появления карточки
    _cardController.forward();

    // 2. Анимация emoji (с небольшой задержкой)
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _emojiController.forward();
    }

    // 3. Анимация печати заголовка (после завершения emoji)
    await Future.delayed(widget.emojiAnimationDuration);
    if (mounted) {
      _titleController.forward();
    }

    // 4. Анимация описания (после завершения заголовка)
    await Future.delayed(widget.textAnimationDuration);
    if (mounted) {
      _descriptionController.forward();
    }
  }

  @override
  void dispose() {
    _emojiController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _cardController,
        _emojiController,
        _titleController,
        _descriptionController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: Opacity(
            opacity: _cardOpacityAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: const EdgeInsets.all(8.0),
                child: GlassSurface(
                  blurStrength: 15.0,
                  borderRadius: BorderRadius.circular(20.0),
                  baseColor: widget.insight.accentColor.withOpacity(0.1),
                  borderColor: widget.insight.accentColor.withOpacity(0.3),
                  borderWidth: 1.5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji с анимацией
                        _buildAnimatedEmoji(),

                        const SizedBox(height: 16),

                        // Заголовок с анимацией печати
                        _buildAnimatedTitle(),

                        const SizedBox(height: 12),

                        // Описание с анимацией появления
                        _buildAnimatedDescription(),

                        const Spacer(),

                        // Индикатор загрузки (пока анимируется)
                        if (_isAnimating && !_descriptionController.isCompleted)
                          _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Создание анимированной emoji
  Widget _buildAnimatedEmoji() {
    return Transform.scale(
      scale: _emojiScaleAnimation.value,
      child: Transform.rotate(
        angle: _emojiRotationAnimation.value,
        child: Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.insight.accentColor.withOpacity(0.2),
            border: Border.all(
              color: widget.insight.accentColor.withOpacity(0.4),
              width: 2.0,
            ),
          ),
          child: Center(
            child: Text(
              widget.insight.emoji,
              style: const TextStyle(fontSize: 32.0),
            ),
          ),
        ),
      ),
    );
  }

  /// Создание анимированного заголовка
  Widget _buildAnimatedTitle() {
    return Opacity(
      opacity: _titleOpacityAnimation.value,
      child: SizedBox(
        height: 24.0,
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              widget.insight.title,
              textStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: widget.insight.accentColor,
                height: 1.2,
              ),
              speed: const Duration(milliseconds: 50),
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
        ),
      ),
    );
  }

  /// Создание анимированного описания
  Widget _buildAnimatedDescription() {
    return Transform.translate(
      offset: Offset(0, _descriptionSlideAnimation.value),
      child: Opacity(
        opacity: _descriptionController.value,
        child: Text(
          widget.insight.description,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white.withOpacity(0.9),
            height: 1.4,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Создание индикатора загрузки
  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 16.0,
          height: 16.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.insight.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Виджет карусели инсайтов
class InsightCarousel extends StatefulWidget {
  /// Список инсайтов для отображения
  final List<AIInsight> insights;

  /// Высота карусели
  final double height;

  /// Колбэк при изменении текущего инсайта
  final ValueChanged<int>? onPageChanged;

  /// Автоматическое пролистывание
  final bool autoPlay;

  const InsightCarousel({
    super.key,
    required this.insights,
    this.height = 220.0,
    this.onPageChanged,
    this.autoPlay = false,
  });

  @override
  State<InsightCarousel> createState() => _InsightCarouselState();
}

class _InsightCarouselState extends State<InsightCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.autoPlay && widget.insights.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _nextPage();
      }
    });
  }

  void _nextPage() {
    final nextIndex = (_currentIndex + 1) % widget.insights.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.insights.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            'Нет доступных инсайтов',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Карусель инсайтов
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.insights.length,
            itemBuilder: (context, index) {
              final insight = widget.insights[index];
              return InsightCard(
                insight: insight,
                height: widget.height,
                width: MediaQuery.of(context).size.width - 32,
                animationDelay: Duration(milliseconds: index * 200),
                onTap: () {
                  // Можно добавить дополнительную логику при тапе
                },
              );
            },
          ),
        ),

        // Индикаторы страниц
        if (widget.insights.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.insights.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentIndex == index ? 12.0 : 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
