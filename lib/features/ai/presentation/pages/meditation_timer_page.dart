import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/meditation_entity.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/meditation_audio_service.dart';

/// Экран медитации с таймером
class MeditationTimerPage extends StatefulWidget {
  final MeditationEntity meditation;

  const MeditationTimerPage({super.key, required this.meditation});

  @override
  State<MeditationTimerPage> createState() => _MeditationTimerPageState();
}

class _MeditationTimerPageState extends State<MeditationTimerPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _currentInstructionIndex = 0;

  final MeditationAudioService _audioService = MeditationAudioService();
  MeditationSoundType _selectedSound = MeditationSoundType.nature;
  bool _soundEnabled = true;
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.meditation.duration * 60;
    // Инициализируем аудио асинхронно после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
  }

  Future<void> _initializeAudio() async {
    if (!_audioInitialized) {
      await _audioService.initialize();
      _audioInitialized = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Останавливаем звук, но не dispose сервиса (он singleton)
    _audioService.stop();
    super.dispose();
  }

  void _startTimer() async {
    final wasPaused = _isPaused;

    setState(() {
      if (_isPaused) {
        _isPaused = false;
      }
      _isRunning = true;
    });

    // Запускаем или возобновляем звук медитации
    if (wasPaused) {
      // Возобновляем звук после паузы
      if (_soundEnabled && _selectedSound != MeditationSoundType.silence) {
        debugPrint('🔊 Возобновляем звук медитации: $_selectedSound');
        await _audioService.resume();
      }
    } else {
      // Запускаем звук медитации
      if (_soundEnabled && _selectedSound != MeditationSoundType.silence) {
        debugPrint('🔊 Запускаем звук медитации: $_selectedSound');
        await _audioService.playMeditationSound(
          type: _selectedSound,
          volume: 0.3,
        );
      } else {
        debugPrint('🔇 Звук отключен или выбран режим тишины');
      }
    }

    _timer?.cancel();
    int lastInstructionUpdate = _remainingSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;

          // Обновляем инструкцию каждые 30 секунд
          final secondsElapsed = lastInstructionUpdate - _remainingSeconds;
          if (secondsElapsed >= 30 &&
              _currentInstructionIndex <
                  widget.meditation.instructions.length - 1) {
            _currentInstructionIndex++;
            lastInstructionUpdate = _remainingSeconds;
          }
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isRunning = false;
          });
          _showCompletionDialog();
        }
      }
    });
  }

  void _pauseTimer() async {
    _timer?.cancel();
    // Пауза звука
    if (_soundEnabled) {
      await _audioService.pause();
    }
    if (mounted) {
      setState(() {
        _isPaused = true;
        _isRunning = false;
      });
    }
  }

  void _stopTimer() async {
    _timer?.cancel();
    // Останавливаем звук
    await _audioService.stop();
    if (mounted) {
      setState(() {
        _isRunning = false;
        _isPaused = false;
        _remainingSeconds = widget.meditation.duration * 60;
        _currentInstructionIndex = 0;
      });
    }
  }

  void _showCompletionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('ai.meditation.completed'.tr()),
        content: Text('ai.meditation.completed_message'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
              if (mounted) {
                Navigator.of(context).pop(); // Возвращаемся на предыдущий экран
              }
            },
            child: Text('common.done'.tr()),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : colorScheme.surface,
      appBar: AppBar(
        title: Text('ai.meditation.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E293B) : colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_isRunning || _isPaused) {
              _showStopConfirmation();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Таймер
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Эмодзи медитации - еще уменьшаем
                      Text(
                        widget.meditation.emoji,
                        style: const TextStyle(fontSize: 50),
                      ),
                      const SizedBox(height: 20),
                      // Время - делаем более заметным
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: widget.meditation.accentColor.withOpacity(
                              0.5,
                            ),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.meditation.accentColor.withOpacity(
                                0.2,
                              ),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: AppTypography.h1.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: widget.meditation.accentColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Название медитации
                      Text(
                        widget.meditation.title,
                        style: AppTypography.h3.copyWith(
                          fontSize: 20,
                          color: isDark ? Colors.white : colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Описание медитации
                      Text(
                        widget.meditation.description,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Текущая инструкция
            if (widget.meditation.instructions.isNotEmpty)
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.meditation.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ai.meditation.current_step'.tr(),
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? Colors.white70
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.meditation.instructions[_currentInstructionIndex
                            .clamp(
                              0,
                              widget.meditation.instructions.length - 1,
                            )],
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark ? Colors.white : colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Кнопки управления звуком
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _soundEnabled = !_soundEnabled;
                      });
                      if (!_soundEnabled) {
                        _audioService.stop();
                      } else if (_isRunning &&
                          _selectedSound != MeditationSoundType.silence) {
                        _audioService.playMeditationSound(
                          type: _selectedSound,
                          volume: 0.3,
                        );
                      }
                    },
                    icon: Icon(
                      _soundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _soundEnabled
                          ? widget.meditation.accentColor
                          : colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (_soundEnabled)
                    PopupMenuButton<MeditationSoundType>(
                      icon: Icon(
                        Icons.music_note,
                        color: widget.meditation.accentColor,
                      ),
                      onSelected: (type) async {
                        setState(() {
                          _selectedSound = type;
                        });
                        if (_isRunning) {
                          await _audioService.stop();
                          if (type != MeditationSoundType.silence) {
                            await _audioService.playMeditationSound(
                              type: type,
                              volume: 0.3,
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => MeditationSoundType.values
                          .map(
                            (type) => PopupMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Text(type.emoji),
                                  const SizedBox(width: 8),
                                  Text(type.displayName),
                                  if (_selectedSound == type) ...[
                                    const Spacer(),
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: widget.meditation.accentColor,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),

            // Кнопки управления
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Стоп
                  if (_isRunning || _isPaused)
                    IconButton(
                      onPressed: _stopTimer,
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      color: colorScheme.error,
                    ),
                  // Пауза/Продолжить
                  if (_isRunning || _isPaused)
                    IconButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      iconSize: 48,
                      color: widget.meditation.accentColor,
                    ),
                  // Старт
                  if (!_isRunning && !_isPaused)
                    ElevatedButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: Text('ai.meditation.start'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.meditation.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ai.meditation.stop_title'.tr()),
        content: Text('ai.meditation.stop_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              _stopTimer();
              context.pop(); // Закрываем диалог
              context.pop(); // Возвращаемся на предыдущий экран
            },
            child: Text('common.stop'.tr()),
          ),
        ],
      ),
    );
  }
}
