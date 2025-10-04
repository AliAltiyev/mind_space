import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/database/database.dart';
import '../../widgets/core/amazing_background.dart' as amazing;
import '../../widgets/core/amazing_glass_surface.dart' as amazing;
import '../../widgets/core/perfected_mood_blob.dart';

/// Экран добавления новой записи настроения с потрясающим UI
class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _moodController;

  int _selectedMood = 3;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _moodEmojis = ['😢', '😔', '😐', '😊', '🤩'];
  final List<String> _moodLabels = [
    'Очень плохо',
    'Плохо',
    'Нормально',
    'Хорошо',
    'Отлично',
  ];
  final List<Color> _moodColors = [
    const Color(0xFFEA2F14), // Rich Red - очень плохо
    const Color(0xFFE6521F), // Deep Orange-Red - плохо
    const Color(0xFFFB9E3A), // Vibrant Orange - нормально
    const Color(0xFFFCEF91), // Warm Yellow/Cream - хорошо
    const Color(0xFFFCEF91), // Warm Yellow/Cream - отлично
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _moodController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Запускаем анимации
    _fadeController.forward();
    _slideController.forward();
    _moodController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _moodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFB9E3A), Color(0xFFE6521F)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFB9E3A).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      title: const Text(
        'Добавить запись',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE6521F), Color(0xFFEA2F14)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE6521F).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextButton(
            onPressed: _saveEntry,
            child: const Text(
              'Сохранить',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              ),
            ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Заголовок
                _buildHeader(),

                const SizedBox(height: 40),

                // MoodBlob для выбора настроения
                _buildMoodSelector(),

                const SizedBox(height: 40),

                // Поле для заметки
                _buildNoteField(),

                const SizedBox(height: 40),

                // Дополнительные опции
                _buildAdditionalOptions(),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.neon,
      colorScheme: amazing.ColorScheme.neon,
      child: Column(
        children: [
          Text(
            'Как дела?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: const Color(0xFFFB9E3A), blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Поделитесь своим настроением',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              shadows: [
                Shadow(
                  color: const Color(0xFFFB9E3A).withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return ScaleTransition(
      scale: _moodController,
      child: amazing.AmazingGlassSurface(
        effectType: amazing.GlassEffectType.cosmic,
        colorScheme: amazing.ColorScheme.cosmic,
        child: Column(
          children: [
            Text(
              'Выберите настроение',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: const Color(0xFFFB9E3A), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // MoodBlob с анимацией
            SizedBox(
              width: 200,
              height: 200,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = (_selectedMood + 1) % 5;
                  });
                  _moodController.reset();
                  _moodController.forward();
                },
                child: PerfectedMoodBlob(
                  moodRating: _selectedMood + 1,
                  onTap: () {},
                  size: 200,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Слайдер настроения
            _buildMoodSlider(),

            const SizedBox(height: 16),

            // Текущее настроение
            _buildCurrentMood(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index == _selectedMood;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = index;
                });
                _moodController.reset();
                _moodController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? RadialGradient(
                          colors: [
                            _moodColors[index].withOpacity(0.8),
                            _moodColors[index].withOpacity(0.3),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? _moodColors[index]
                        : Colors.white.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _moodColors[index].withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _moodEmojis[index],
                    style: TextStyle(fontSize: isSelected ? 28 : 24),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurrentMood() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _moodColors[_selectedMood].withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _moodColors[_selectedMood].withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        _moodLabels[_selectedMood],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _moodColors[_selectedMood],
          shadows: [
            Shadow(
              color: _moodColors[_selectedMood].withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.cyber,
      colorScheme: amazing.ColorScheme.cyber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Добавить заметку (необязательно)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: const Color(0xFFFCEF91), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF41).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFCEF91).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Расскажите, что повлияло на ваше настроение...',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.rainbow,
      colorScheme: amazing.ColorScheme.rainbow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дополнительно',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: const Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 16),

          // Дата и время
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFB9E3A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: const Color(0xFFFB9E3A),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Сейчас: ${_getCurrentTime()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFB9E3A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: const Color(0xFFFB9E3A),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Это будет ваша 1-я запись сегодня',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.day}.${now.month.toString().padLeft(2, '0')}.${now.year} в ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEntry() async {
    try {
      final database = ref.read(appDatabaseProvider);

      final entry = MoodEntry(
        moodValue: _selectedMood + 1,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем в базу данных
      await database.addMoodEntry(entry);

      // Показываем уведомление об успехе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Запись успешно сохранена! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF38A169),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Возвращаемся на главный экран
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка при сохранении: $e',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
