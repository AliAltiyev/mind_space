import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/navigation.dart';

/// Фазы медитации
enum MeditationPhase {
  preparation, // Подготовка
  breathing, // Дыхание
  bodyScan, // Сканирование тела
  visualization, // Визуализация
  completion, // Завершение
}

/// Модель фазы медитации
class MeditationPhaseModel {
  final MeditationPhase phase;
  final String title;
  final List<String> instructions;
  final int durationSeconds; // Длительность фазы в секундах

  const MeditationPhaseModel({
    required this.phase,
    required this.title,
    required this.instructions,
    required this.durationSeconds,
  });

  /// Получить инструкции для фазы
  List<String> getInstructions() {
    // Локализованные инструкции - используем EasyLocalization через navigatorKey
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        debugPrint('⚠️ Контекст недоступен, используем fallback инструкции');
        return getFallbackInstructions();
      }

      final easyLocalization = EasyLocalization.of(context);
      if (easyLocalization == null) {
        debugPrint(
          '⚠️ EasyLocalization недоступен, используем fallback инструкции',
        );
        return getFallbackInstructions();
      }

      // Получаем текущую локаль для определения языка fallback
      final currentLocale = easyLocalization.locale;
      final isRussian = currentLocale.languageCode == 'ru';

      // Пробуем перевести инструкции через контекст
      List<String> translatedInstructions = [];
      switch (phase) {
        case MeditationPhase.preparation:
          translatedInstructions = [
            context.tr('meditation.phase.preparation.1'),
            context.tr('meditation.phase.preparation.2'),
            context.tr('meditation.phase.preparation.3'),
          ];
          break;
        case MeditationPhase.breathing:
          translatedInstructions = [
            context.tr('meditation.phase.breathing.1'),
            context.tr('meditation.phase.breathing.2'),
            context.tr('meditation.phase.breathing.3'),
            context.tr('meditation.phase.breathing.4'),
          ];
          break;
        case MeditationPhase.bodyScan:
          translatedInstructions = [
            context.tr('meditation.phase.body_scan.1'),
            context.tr('meditation.phase.body_scan.2'),
            context.tr('meditation.phase.body_scan.3'),
          ];
          break;
        case MeditationPhase.visualization:
          translatedInstructions = [
            context.tr('meditation.phase.visualization.1'),
            context.tr('meditation.phase.visualization.2'),
            context.tr('meditation.phase.visualization.3'),
          ];
          break;
        case MeditationPhase.completion:
          translatedInstructions = [
            context.tr('meditation.phase.completion.1'),
            context.tr('meditation.phase.completion.2'),
            context.tr('meditation.phase.completion.3'),
          ];
          break;
      }

      // Проверяем, что инструкции переведены (не являются ключами)
      final hasUntranslated = translatedInstructions.any(
        (instruction) => instruction.startsWith('meditation.phase.'),
      );

      if (hasUntranslated) {
        debugPrint(
          '⚠️ Некоторые инструкции не переведены, используем fallback',
        );
        debugPrint('🌐 Текущая локаль: ${currentLocale.languageCode}');
        // Если русский язык, используем русские fallback инструкции
        if (isRussian) {
          return getRussianFallbackInstructions();
        }
        // Иначе используем английские fallback инструкции
        return getFallbackInstructions();
      }

      debugPrint(
        '✅ Инструкции переведены на язык: ${currentLocale.languageCode}',
      );
      return translatedInstructions;
    } catch (e) {
      // Fallback на английские тексты если локализация не работает
      debugPrint('⚠️ Ошибка локализации инструкций: $e');
      return getFallbackInstructions();
    }
  }

  /// Fallback инструкции на английском (публичный для доступа из провайдера)
  List<String> getFallbackInstructions() {
    switch (phase) {
      case MeditationPhase.preparation:
        return [
          'Find a comfortable position. Close your eyes if you feel comfortable.',
          'Take a moment to settle into this space.',
          'Let go of any expectations and be present.',
        ];
      case MeditationPhase.breathing:
        return [
          'Take a deep breath in through your nose.',
          'Hold for a moment, then slowly exhale through your mouth.',
          'Continue breathing naturally and deeply.',
          'Focus your attention on your breath.',
        ];
      case MeditationPhase.bodyScan:
        return [
          'Slowly scan your body from head to toe.',
          'Notice any tension or discomfort without judgment.',
          'Allow your body to relax and release.',
        ];
      case MeditationPhase.visualization:
        return [
          'Imagine a peaceful place where you feel safe and calm.',
          'Visualize yourself in this place, fully present.',
          'Take in all the details of this peaceful space.',
        ];
      case MeditationPhase.completion:
        return [
          'Slowly bring your awareness back to the present moment.',
          'Wiggle your fingers and toes gently.',
          'When you\'re ready, open your eyes.',
        ];
    }
  }

  /// Fallback инструкции на русском языке
  List<String> getRussianFallbackInstructions() {
    switch (phase) {
      case MeditationPhase.preparation:
        return [
          'Найдите удобное положение. Закройте глаза, если вам комфортно.',
          'Потратьте момент, чтобы устроиться в этом пространстве.',
          'Отпустите все ожидания и будьте здесь и сейчас.',
        ];
      case MeditationPhase.breathing:
        return [
          'Сделайте глубокий вдох через нос.',
          'Задержите дыхание на мгновение, затем медленно выдохните через рот.',
          'Продолжайте дышать естественно и глубоко.',
          'Сосредоточьте внимание на своем дыхании.',
        ];
      case MeditationPhase.bodyScan:
        return [
          'Медленно просканируйте свое тело с головы до ног.',
          'Обратите внимание на любое напряжение или дискомфорт без осуждения.',
          'Позвольте своему телу расслабиться и освободиться.',
        ];
      case MeditationPhase.visualization:
        return [
          'Представьте спокойное место, где вы чувствуете себя в безопасности и спокойствии.',
          'Визуализируйте себя в этом месте, полностью присутствуя здесь.',
          'Воспримите все детали этого мирного пространства.',
        ];
      case MeditationPhase.completion:
        return [
          'Медленно верните свое осознание в настоящий момент.',
          'Пошевелите пальцами рук и ног мягко.',
          'Когда будете готовы, откройте глаза.',
        ];
    }
  }

  /// Получить название фазы
  String getTitle() {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        debugPrint('⚠️ Контекст недоступен для getTitle, используем fallback');
        return _getFallbackTitle();
      }

      final easyLocalization = EasyLocalization.of(context);
      if (easyLocalization == null) {
        debugPrint('⚠️ EasyLocalization недоступен для getTitle, используем fallback');
        return _getFallbackTitle();
      }

      String title;
      switch (phase) {
        case MeditationPhase.preparation:
          title = context.tr('meditation.phase.preparation.title');
          break;
        case MeditationPhase.breathing:
          title = context.tr('meditation.phase.breathing.title');
          break;
        case MeditationPhase.bodyScan:
          title = context.tr('meditation.phase.body_scan.title');
          break;
        case MeditationPhase.visualization:
          title = context.tr('meditation.phase.visualization.title');
          break;
        case MeditationPhase.completion:
          title = context.tr('meditation.phase.completion.title');
          break;
      }

      // Проверяем, что заголовок переведен (не является ключом)
      if (title.startsWith('meditation.phase.')) {
        debugPrint('⚠️ Заголовок не переведен: $title, используем fallback');
        return _getFallbackTitle();
      }

      return title;
    } catch (e) {
      debugPrint('⚠️ Ошибка локализации заголовка: $e');
      return _getFallbackTitle();
    }
  }

  /// Fallback заголовок на английском
  String _getFallbackTitle() {
    switch (phase) {
      case MeditationPhase.preparation:
        return 'Preparation';
      case MeditationPhase.breathing:
        return 'Breathing';
      case MeditationPhase.bodyScan:
        return 'Body Scan';
      case MeditationPhase.visualization:
        return 'Visualization';
      case MeditationPhase.completion:
        return 'Completion';
    }
  }

  /// Создать фазы для медитации
  static List<MeditationPhaseModel> createPhases(int totalDurationMinutes) {
    final totalSeconds = totalDurationMinutes * 60;

    // Распределение времени по фазам (в процентах)
    final prepSeconds = (totalSeconds * 0.1).round(); // 10%
    final breathingSeconds = (totalSeconds * 0.3).round(); // 30%
    final bodyScanSeconds = (totalSeconds * 0.3).round(); // 30%
    final visualizationSeconds = (totalSeconds * 0.2).round(); // 20%
    final completionSeconds = (totalSeconds * 0.1).round(); // 10%

    return [
      MeditationPhaseModel(
        phase: MeditationPhase.preparation,
        title: '', // Заголовок будет получен через getTitle()
        instructions: [],
        durationSeconds: prepSeconds,
      ),
      MeditationPhaseModel(
        phase: MeditationPhase.breathing,
        title: '',
        instructions: [],
        durationSeconds: breathingSeconds,
      ),
      MeditationPhaseModel(
        phase: MeditationPhase.bodyScan,
        title: '',
        instructions: [],
        durationSeconds: bodyScanSeconds,
      ),
      MeditationPhaseModel(
        phase: MeditationPhase.visualization,
        title: '',
        instructions: [],
        durationSeconds: visualizationSeconds,
      ),
      MeditationPhaseModel(
        phase: MeditationPhase.completion,
        title: '',
        instructions: [],
        durationSeconds: completionSeconds,
      ),
    ];
  }
}
