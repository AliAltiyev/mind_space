import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/meditation_entity.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/meditation_audio_service.dart';
import '../../providers/meditation_tts_provider.dart';
import '../../models/meditation_phase.dart';
import '../widgets/breathing_visualization.dart';
import '../widgets/audio_controls.dart';

/// Экран медитации с таймером и TTS
class MeditationTimerPageTTS extends ConsumerStatefulWidget {
  final MeditationEntity meditation;

  const MeditationTimerPageTTS({super.key, required this.meditation});

  @override
  ConsumerState<MeditationTimerPageTTS> createState() =>
      _MeditationTimerPageTTSState();
}

class _MeditationTimerPageTTSState
    extends ConsumerState<MeditationTimerPageTTS> {
  Timer? _timer;
  final MeditationAudioService _audioService = MeditationAudioService();
  MeditationSoundType _selectedSound = MeditationSoundType.nature;
  bool _soundEnabled = true;
  bool _audioInitialized = false;
  bool _showAudioControls = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeAudio();
      // Инициализируем TTS провайдер
      await ref
          .read(meditationTTSProvider(widget.meditation).notifier)
          .initialize();
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
    _audioService.stop();
    ref.read(meditationTTSProvider(widget.meditation).notifier).stop();
    super.dispose();
  }

  void _startTimer() async {
    final ttsNotifier = ref.read(
      meditationTTSProvider(widget.meditation).notifier,
    );
    final ttsState = ref.read(meditationTTSProvider(widget.meditation));

    // Запускаем TTS медитацию (она сама управляет таймером)
    await ttsNotifier.start();

    // Запускаем фоновую музыку
    if (_soundEnabled && _selectedSound != MeditationSoundType.silence) {
      await _audioService.playMeditationSound(
        type: _selectedSound,
        volume: ttsState.musicVolume,
      );
    }
  }

  void _pauseTimer() async {
    final ttsNotifier = ref.read(
      meditationTTSProvider(widget.meditation).notifier,
    );
    await ttsNotifier.pause();
    await _audioService.pause();
    _timer?.cancel();
  }

  void _resumeTimer() async {
    final ttsNotifier = ref.read(
      meditationTTSProvider(widget.meditation).notifier,
    );
    await ttsNotifier.resume();
    await _audioService.resume();
  }

  void _stopTimer() async {
    final ttsNotifier = ref.read(
      meditationTTSProvider(widget.meditation).notifier,
    );
    await ttsNotifier.stop();
    await _audioService.stop();
    _timer?.cancel();
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
              Navigator.of(context).pop();
              if (mounted) {
                Navigator.of(context).pop();
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

  String _getPhaseTitle(MeditationPhase? meditationPhase) {
    if (meditationPhase == null) return '';
    switch (meditationPhase) {
      case MeditationPhase.preparation:
        return 'meditation.phase.preparation.title'.tr();
      case MeditationPhase.breathing:
        return 'meditation.phase.breathing.title'.tr();
      case MeditationPhase.bodyScan:
        return 'meditation.phase.body_scan.title'.tr();
      case MeditationPhase.visualization:
        return 'meditation.phase.visualization.title'.tr();
      case MeditationPhase.completion:
        return 'meditation.phase.completion.title'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ttsState = ref.watch(meditationTTSProvider(widget.meditation));
    final ttsNotifier = ref.read(
      meditationTTSProvider(widget.meditation).notifier,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Используем оставшееся время из состояния TTS
    int remainingSeconds = ttsState.remainingSeconds;

    // Проверяем завершение медитации
    if (remainingSeconds <= 0 && ttsState.isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompletionDialog();
      });
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : colorScheme.surface,
      appBar: AppBar(
        title: Text('ai.meditation.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E293B) : colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (ttsState.isPlaying || ttsState.isPaused) {
              _showStopConfirmation();
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_showAudioControls ? Icons.volume_up : Icons.settings),
            onPressed: () {
              setState(() {
                _showAudioControls = !_showAudioControls;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Таймер и визуализация
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
                      // Индикатор текущей фазы
                      if (ttsState.currentPhase != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.meditation.accentColor.withOpacity(
                              0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.meditation.accentColor.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            _getPhaseTitle(ttsState.currentPhase),
                            style: AppTypography.bodyMedium.copyWith(
                              color: widget.meditation.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Визуализация дыхания (показываем только в фазе дыхания)
                      if (ttsState.currentPhase == MeditationPhase.breathing)
                        BreathingVisualization(
                          color: widget.meditation.accentColor,
                          size: 200,
                        )
                      else
                        // Эмодзи медитации
                        Text(
                          widget.meditation.emoji,
                          style: const TextStyle(fontSize: 50),
                        ),

                      const SizedBox(height: 20),

                      // Таймер
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
                          _formatTime(remainingSeconds),
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

                      // Текущая инструкция (из TTS)
                      if (ttsState.currentInstruction != null)
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.meditation.accentColor.withOpacity(
                                0.3,
                              ),
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
                                ttsState.currentInstruction!,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      // Информация о TTS
                      if (!ttsState.isInitialized)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'ai.meditation.audio.tts_unavailable'.tr(),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.white60
                                  : colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Контролы аудио (показываем по требованию)
            if (_showAudioControls)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: AudioControls(
                  musicVolume: ttsState.musicVolume,
                  voiceVolume: ttsState.voiceVolume,
                  onMusicVolumeChanged: (volume) async {
                    await ttsNotifier.setMusicVolume(volume);
                    await _audioService.setVolume(volume);
                  },
                  onVoiceVolumeChanged: (volume) async {
                    await ttsNotifier.setVoiceVolume(volume);
                  },
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
                      } else if (ttsState.isPlaying &&
                          _selectedSound != MeditationSoundType.silence) {
                        _audioService.playMeditationSound(
                          type: _selectedSound,
                          volume: ttsState.musicVolume,
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
                        if (ttsState.isPlaying) {
                          await _audioService.stop();
                          if (type != MeditationSoundType.silence) {
                            await _audioService.playMeditationSound(
                              type: type,
                              volume: ttsState.musicVolume,
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
                  if (ttsState.isPlaying || ttsState.isPaused)
                    IconButton(
                      onPressed: _stopTimer,
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      color: colorScheme.error,
                    ),
                  // Пауза/Продолжить
                  if (ttsState.isPlaying || ttsState.isPaused)
                    IconButton(
                      onPressed: ttsState.isPlaying
                          ? _pauseTimer
                          : _resumeTimer,
                      icon: Icon(
                        ttsState.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      iconSize: 48,
                      color: widget.meditation.accentColor,
                    ),
                  // Старт
                  if (!ttsState.isPlaying && !ttsState.isPaused)
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
              context.pop();
              context.pop();
            },
            child: Text('common.stop'.tr()),
          ),
        ],
      ),
    );
  }
}
