import 'package:flutter/material.dart';

/// Анимированная иконка настроения с плавными переходами
///
/// Виджет отображает emoji или другую иконку настроения в зависимости от рейтинга
/// (от 1 до 5) и анимирует изменения с эффектом масштабирования.
///
/// При изменении рейтинга иконка плавно увеличивается и возвращается к исходному размеру,
/// создавая приятный визуальный эффект.
class AnimatedMoodIcon extends StatefulWidget {
  /// Рейтинг настроения от 1 до 5
  ///
  /// 1 - очень плохое настроение (😢)
  /// 2 - плохое настроение (😕)
  /// 3 - нейтральное настроение (😐)
  /// 4 - хорошее настроение (😊)
  /// 5 - отличное настроение (😄)
  final int rating;

  /// Базовый размер иконки в пикселях
  final double size;

  /// Включает или отключает анимацию при изменении рейтинга
  final bool animated;

  /// Продолжительность анимации масштабирования
  final Duration duration;

  /// Кривая анимации для эффекта масштабирования
  final Curve curve;

  const AnimatedMoodIcon({
    super.key,
    required this.rating,
    required this.size,
    this.animated = true,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutBack,
  }) : assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

  @override
  State<AnimatedMoodIcon> createState() => _AnimatedMoodIconState();
}

class _AnimatedMoodIconState extends State<AnimatedMoodIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  /// Карта рейтингов к соответствующим emoji
  static const Map<int, String> _moodEmojis = {
    1: '😢', // Очень плохое настроение
    2: '😕', // Плохое настроение
    3: '😐', // Нейтральное настроение
    4: '😊', // Хорошее настроение
    5: '😄', // Отличное настроение
  };

  /// Карта рейтингов к соответствующим градиентам
  static const Map<int, List<Color>> _moodGradients = {
    1: [Color(0xFF6B73FF), Color(0xFF9B59B6)], // Синий-фиолетовый
    2: [Color(0xFF74B9FF), Color(0xFF0984E3)], // Голубой
    3: [Color(0xFF81ECEC), Color(0xFF00B894)], // Бирюзовый
    4: [Color(0xFFFFEAA7), Color(0xFFFDCB6E)], // Желтый
    5: [Color(0xFFFF7675), Color(0xFFE84393)], // Розово-красный
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(AnimatedMoodIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Запускаем анимацию только если рейтинг изменился и анимация включена
    if (oldWidget.rating != widget.rating && widget.animated) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() async {
    if (_controller.isAnimating) {
      _controller.stop();
    }

    _controller.reset();
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _moodEmojis[widget.rating] ?? '😐';
    final gradient = _moodGradients[widget.rating] ?? _moodGradients[3]!;

    return AnimatedContainer(
      duration: widget.animated ? widget.duration : Duration.zero,
      width: widget.size + 20, // Дополнительное пространство для градиента
      height: widget.size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.animated ? _scaleAnimation.value : 1.0,
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: widget.size,
                  height: 1.0, // Убираем лишнюю высоту строки
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Предустановленные стили для AnimatedMoodIcon
class AnimatedMoodIconStyles {
  AnimatedMoodIconStyles._();

  /// Маленький размер для использования в списках
  static const double small = 32.0;

  /// Средний размер для карточек
  static const double medium = 48.0;

  /// Большой размер для главных экранов
  static const double large = 64.0;

  /// Очень большой размер для демонстрации
  static const double extraLarge = 80.0;

  /// Быстрая анимация
  static const Duration fast = Duration(milliseconds: 300);

  /// Стандартная анимация
  static const Duration normal = Duration(milliseconds: 600);

  /// Медленная анимация
  static const Duration slow = Duration(milliseconds: 1000);

  /// Кривые анимации
  static const Curve bounce = Curves.easeOutBack;
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve elastic = Curves.elasticOut;
}

/// Вспомогательный виджет для отображения набора настроений
class MoodIconSet extends StatelessWidget {
  /// Текущий выбранный рейтинг
  final int selectedRating;

  /// Размер иконок
  final double size;

  /// Расстояние между иконками
  final double spacing;

  /// Колбэк при выборе настроения
  final ValueChanged<int> onRatingChanged;

  const MoodIconSet({
    super.key,
    required this.selectedRating,
    this.size = 48.0,
    this.spacing = 16.0,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isSelected = rating == selectedRating;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: GestureDetector(
            onTap: () => onRatingChanged(rating),
            child: AnimatedMoodIcon(
              rating: rating,
              size: isSelected ? size * 1.1 : size * 0.9,
              animated: true,
              duration: const Duration(milliseconds: 400),
            ),
          ),
        );
      }),
    );
  }
}
