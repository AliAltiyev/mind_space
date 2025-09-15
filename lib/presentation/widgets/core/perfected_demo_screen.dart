import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'animated_mood_icon.dart';
import 'glass_surface.dart';
import 'mood_blob_improvements.dart';
import 'perfected_mood_blob.dart';

/// Демонстрационный экран для совершенных виджетов MoodBlob
class PerfectedDemoScreen extends ConsumerStatefulWidget {
  const PerfectedDemoScreen({super.key});

  @override
  ConsumerState<PerfectedDemoScreen> createState() => _PerfectedDemoScreenState();
}

class _PerfectedDemoScreenState extends ConsumerState<PerfectedDemoScreen>
    with TickerProviderStateMixin {
  
  int _currentMood = 3;
  late AnimationController _themeTransitionController;
  
  late Animation<double> _themeScaleAnimation;
  
  bool _enableAnimations = true;
  bool _enableParallax = true;

  @override
  void initState() {
    super.initState();
    _initializeAdvancedAnimations();
  }

  void _initializeAdvancedAnimations() {
    // Контроллер для перехода между темами
    _themeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _themeScaleAnimation = MoodBlobImprovements.createThemeScaleAnimation(
      _themeTransitionController,
    );
  }

  @override
  void dispose() {
    _themeTransitionController.dispose();
    super.dispose();
  }

  void _changeMood(int newMood) {
    setState(() {
      _currentMood = newMood;
    });
    
    // Запускаем анимацию перехода темы
    _themeTransitionController.forward().then((_) {
      _themeTransitionController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfected MoodBlob Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_enableAnimations ? Icons.animation : Icons.animation_outlined),
            onPressed: () {
              setState(() {
                _enableAnimations = !_enableAnimations;
              });
            },
            tooltip: 'Toggle Animations',
          ),
          IconButton(
            icon: Icon(_enableParallax ? Icons.blur_on : Icons.blur_off),
            onPressed: () {
              setState(() {
                _enableParallax = !_enableParallax;
              });
            },
            tooltip: 'Toggle Parallax',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                const Text(
                  'Perfected MoodBlob Showcase',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Демонстрация всех улучшений и оптимизаций',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                // Основной совершенный MoodBlob
                Center(
                  child: MoodBlobImprovements.createSemanticMoodBlob(
                    moodRating: _currentMood,
                    onTap: () => _changeMood((_currentMood % 5) + 1),
                    child: AnimatedBuilder(
                      animation: _themeScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _themeScaleAnimation.value,
                          child: PerfectedMoodBlobWithFAB(
                            moodRating: _currentMood,
                            size: 220.0,
                            showFAB: true,
                            enableEntranceAnimation: _enableAnimations,
                            onTap: () => _changeMood((_currentMood % 5) + 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Селектор настроения
                const Text(
                  'Select Mood Rating',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final rating = index + 1;
                    final isSelected = rating == _currentMood;
                    
                    return GestureDetector(
                      onTap: () => _changeMood(rating),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected 
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: AnimatedMoodIcon(
                          rating: rating,
                          size: 32.0,
                          animated: _enableAnimations,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Демонстрация улучшений
                const Text(
                  'Advanced Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Параллакс эффект
                if (_enableParallax) ...[
                  const Text(
                    'Parallax Effect',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: MoodBlobImprovements.createParallaxBackground(
                      animationValue: _themeTransitionController.value,
                      intensity: 0.2,
                      child: PerfectedMoodBlob(
                        moodRating: _currentMood,
                        size: 120.0,
                        enableParallax: true,
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Эффект свечения
                const Text(
                  'Glow Effect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: PerfectedMoodBlob(
                    moodRating: _currentMood,
                    size: 120.0,
                    onTap: () {},
                  ).withGlow(
                    color: Colors.white,
                    blurRadius: 20.0,
                    spreadRadius: 5.0,
                  ),
                ),

                const SizedBox(height: 24),

                // Эффект размытия фона
                const Text(
                  'Backdrop Blur Effect',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PerfectedMoodBlob(
                      moodRating: _currentMood,
                      size: 120.0,
                      onTap: () {},
                    ).withBackdropBlur(
                      sigmaX: 15.0,
                      sigmaY: 15.0,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Информация о производительности
                GlassSurface(
                  blurStrength: 10.0,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Optimizations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Кэширование Paint объектов\n'
                          '• Оптимизированные CustomPainter\n'
                          '• RepaintBoundary для изоляции\n'
                          '• Timer-based cleanup для ripple эффектов\n'
                          '• Единая дизайн-система с константами',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
