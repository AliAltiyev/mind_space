import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Виджет для управления громкостью музыки и голоса
class AudioControls extends StatelessWidget {
  final double musicVolume;
  final double voiceVolume;
  final ValueChanged<double> onMusicVolumeChanged;
  final ValueChanged<double> onVoiceVolumeChanged;

  const AudioControls({
    super.key,
    required this.musicVolume,
    required this.voiceVolume,
    required this.onMusicVolumeChanged,
    required this.onVoiceVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Громкость музыки
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'meditation.audio.music_volume'.tr(),
                      style: theme.textTheme.bodySmall,
                    ),
                    Slider(
                      value: musicVolume,
                      onChanged: onMusicVolumeChanged,
                      min: 0.0,
                      max: 1.0,
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              Text(
                '${(musicVolume * 100).toInt()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Громкость голоса
          Row(
            children: [
              Icon(
                Icons.record_voice_over,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'meditation.audio.voice_volume'.tr(),
                      style: theme.textTheme.bodySmall,
                    ),
                    Slider(
                      value: voiceVolume,
                      onChanged: onVoiceVolumeChanged,
                      min: 0.0,
                      max: 1.0,
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              Text(
                '${(voiceVolume * 100).toInt()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
