import 'package:flutter/material.dart';

import '../constants/app_design.dart';
import '../features/mood_tracking/domain/entities/mood_entry.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_selector.dart';

class AddMoodScreen extends StatefulWidget {
  final MoodLevel? initialMood;

  const AddMoodScreen({super.key, this.initialMood});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _rippleController;
  late AnimationController _textController;

  late Animation<double> _appearAnimation;
  late Animation<double> _textAnimation;

  MoodLevel? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  bool _isNoteVisible = false;

  @override
  void initState() {
    super.initState();

    _selectedMood = widget.initialMood;

    _appearController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _appearAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut,
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    _appearController.forward();
  }

  @override
  void dispose() {
    _appearController.dispose();
    _rippleController.dispose();
    _textController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDesign.paddingLarge),
                  child: Column(
                    children: [
                      _buildMoodSelector(),
                      const SizedBox(height: AppDesign.paddingXLarge),
                      if (_isNoteVisible) _buildNoteSection(),
                      const SizedBox(height: AppDesign.paddingXLarge),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.paddingLarge),
      child: Row(
        children: [
          GlassButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.close, color: AppDesign.textPrimary),
          ),
          const SizedBox(width: AppDesign.paddingMedium),
          Text('Записать настроение', style: AppTextStyles.headline3),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return ScaleTransition(
      scale: _appearAnimation,
      child: GlassCard(
        child: Column(
          children: [
            Text(
              'Как вы себя чувствуете?',
              style: AppTextStyles.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.paddingXLarge),
            InteractiveMoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: _onMoodSelected,
              size: 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return FadeTransition(
      opacity: _textAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_textAnimation),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Расскажите подробнее', style: AppTextStyles.headline3),
              const SizedBox(height: AppDesign.paddingMedium),
              TextField(
                controller: _noteController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Что повлияло на ваше настроение?',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppDesign.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
                    borderSide: BorderSide(
                      color: AppDesign.accentColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
                    borderSide: BorderSide(
                      color: AppDesign.accentColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppDesign.surfaceColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return FadeTransition(
      opacity: _textAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_textAnimation),
        child: SizedBox(
          width: double.infinity,
          child: GlassButton(
            onPressed: _selectedMood != null ? _saveMoodEntry : null,
            backgroundColor: _selectedMood != null
                ? AppDesign.accentColor
                : AppDesign.textTertiary,
            child: Text(
              'Сохранить',
              style: AppTextStyles.button.copyWith(
                color: AppDesign.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onMoodSelected(MoodLevel mood) {
    setState(() {
      _selectedMood = mood;
    });

    // Запускаем ripple эффект
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });

    // Показываем поле для заметки
    if (!_isNoteVisible) {
      setState(() {
        _isNoteVisible = true;
      });
      _textController.forward();
    }
  }

  void _saveMoodEntry() {
    if (_selectedMood == null) return;

    // Создаем запись о настроении
    final moodEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: _selectedMood!,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    // Здесь должна быть логика сохранения
    // context.read<MoodTrackingBloc>().add(AddMoodEntry(moodEntry));

    // Временно используем переменную для избежания предупреждения
    print('Сохранение настроения: ${moodEntry.mood.label}');

    // Показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Настроение записано!', style: AppTextStyles.bodyMedium),
        backgroundColor: AppDesign.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        ),
      ),
    );

    // Закрываем экран
    Navigator.pop(context);
  }
}

class RippleEffect extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final double rippleRadius;

  const RippleEffect({
    super.key,
    required this.child,
    required this.rippleColor,
    this.rippleRadius = 100.0,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startRipple() {
    _controller.forward().then((_) {
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: RipplePainter(
            animation: _animation.value,
            color: widget.rippleColor,
            radius: widget.rippleRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animation;
  final Color color;
  final double radius;

  RipplePainter({
    required this.animation,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animation == 0.0) return;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - animation)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final currentRadius = radius * animation;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
