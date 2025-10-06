import '../../features/profile/domain/entities/user_profile_entity.dart';
import '../database/database.dart';
import 'package:easy_localization/easy_localization.dart';

/// Генератор умных промптов для AI
class PromptGenerator {
  PromptGenerator._();

  /// Генерация промпта для AI инсайтов
  static String generateInsightPrompt(List<MoodEntry> recentMoods) {
    if (recentMoods.isEmpty) {
      return _generateEmptyDataPrompt('insights');
    }

    final averageMood =
        recentMoods.map((m) => m.moodValue).reduce((a, b) => a + b) /
        recentMoods.length;
    final moodTrend = _calculateMoodTrend(recentMoods);
    final recentNotes = recentMoods
        .where((m) => m.note?.isNotEmpty == true)
        .take(5)
        .toList();

    return '''
${"prompts.ai_insight_prompt".tr()}

ДАННЫЕ ПОЛЬЗОВАТЕЛЯ:
Количество записей: ${recentMoods.length}
Период: последние ${recentMoods.length} дней
Средний уровень настроения: ${averageMood.toStringAsFixed(1)}/5
Тренд настроения: $moodTrend

ПОСЛЕДНИЕ ЗАПИСИ НАСТРОЕНИЯ:
${recentMoods.take(10).map((m) => '• ${m.createdAt.day}/${m.createdAt.month}: ${m.moodValue}/5${m.note != null ? ' - ${m.note}' : ''}').join('\n')}

${recentNotes.isNotEmpty ? '''
НЕДАВНИЕ ЗАМЕТКИ:
${recentNotes.map((m) => '• "${m.note}"').join('\n')}
''' : ''}

ИНСТРУКЦИИ:
1. Будь поддерживающим и эмпатичным
2. Проанализируй паттерны в данных настроения
3. Предоставь конкретные наблюдения о трендах
4. Предложи 1-2 практических совета для улучшения состояния
5. Используй позитивный и ободряющий тон
6. Ответ должен быть на русском языке
7. Длина: 2-3 абзаца

${"prompts.ai_insight_format".tr()}

Цвета для разных типов инсайтов:
- Позитивные: #4ECDC4, #45B7D1, #96CEB4, #6BCF7F
- Нейтральные: #FFEAA7, #DDA0DD, #98D8C8, #A8E6CF
- Предупреждающие: #FD79A8, #FDCB6E, #E17055, #FF7675
- Мотивирующие: #FFD93D, #E84393, #74B9FF, #00B894
''';
  }

  /// Генерация промпта для анализа паттернов
  static String generatePatternPrompt(List<MoodEntry> moodHistory) {
    if (moodHistory.isEmpty) {
      return _generateEmptyDataPrompt('patterns');
    }

    final weeklyPatterns = _analyzeWeeklyPatterns(moodHistory);
    final monthlyTrends = _analyzeMonthlyTrends(moodHistory);

    return '''
${"prompts.ai_pattern_prompt".tr()}

ДАННЫЕ ДЛЯ АНАЛИЗА:
Общее количество записей: ${moodHistory.length}
Период: ${moodHistory.isNotEmpty ? '${moodHistory.last.createdAt.day}/${moodHistory.last.createdAt.month} - ${moodHistory.first.createdAt.day}/${moodHistory.first.createdAt.month}' : 'N/A'}

СТАТИСТИКА НАСТРОЕНИЯ:
${_generateMoodStatistics(moodHistory)}

НЕДЕЛЬНЫЕ ПАТТЕРНЫ:
$weeklyPatterns

МЕСЯЧНЫЕ ТРЕНДЫ:
$monthlyTrends

ИНСТРУКЦИИ:
1. Выяви ключевые паттерны в данных
2. Определи факторы, влияющие на настроение
3. Предложи рекомендации на основе анализа
4. Используй конкретные данные и примеры
5. Ответ должен быть на русском языке

СФОРМАТИРУЙ ОТВЕТ В ВИДЕ JSON:
{
  "title": "Краткий заголовок анализа (максимум 50 символов)",
  "description": "Подробный анализ паттернов (200-400 символов)",
  "emoji": "Подходящий emoji",
  "accentColor": "hex код цвета",
  "patterns": ["Выявленный паттерн 1", "Выявленный паттерн 2"],
  "recommendations": ["Рекомендация 1", "Рекомендация 2"]
}
''';
  }

  /// Генерация промпта для благодарственных предложений
  static String generateGratitudePrompt(List<MoodEntry> recentMoods) {
    final positiveMoods = recentMoods.where((m) => m.moodValue >= 4).toList();
    final currentMood = recentMoods.isNotEmpty
        ? recentMoods.first.moodValue
        : 3;

    return '''
${"prompts.ai_gratitude_prompt".tr()}

КОНТЕКСТ ПОЛЬЗОВАТЕЛЯ:
Текущее настроение: $currentMood/5
Положительных дней за период: ${positiveMoods.length}/${recentMoods.length}
${recentMoods.isNotEmpty ? 'Последняя заметка: "${recentMoods.first.note ?? 'нет заметки'}"' : ''}

ИНСТРУКЦИИ:
1. Создай 3-5 конкретных предложений для благодарности
2. Учитывай текущее настроение пользователя
3. Предложения должны быть практичными и вдохновляющими
4. Включи разные категории: люди, события, достижения, простые радости
5. Ответ должен быть на русском языке

${"prompts.ai_gratitude_format".tr()}

Цвета для благодарности: #FFD93D, #FFEAA7, #FDCB6E, #E17055
''';
  }

  /// Генерация промпта для медитационных сессий
  static String generateMeditationPrompt(List<MoodEntry> recentMoods) {
    final averageMood = recentMoods.isNotEmpty
        ? recentMoods.map((m) => m.moodValue).reduce((a, b) => a + b) /
              recentMoods.length
        : 3.0;
    final stressLevel = _calculateStressLevel(recentMoods);

    return '''
${"prompts.ai_meditation_prompt".tr()}

АНАЛИЗ СОСТОЯНИЯ:
Средний уровень настроения: ${averageMood.toStringAsFixed(1)}/5
Уровень стресса: $stressLevel
Потребность в расслаблении: ${_getRelaxationNeed(averageMood, stressLevel)}

ИНСТРУКЦИИ:
1. Выбери подходящий тип медитации
2. Предложи конкретную технику
3. Укажи рекомендуемую длительность
4. Дай практические советы
5. Ответ должен быть на русском языке

${"prompts.ai_meditation_format".tr()}

Цвета для медитации: #74B9FF, #0984E3, #81ECEC, #00B894
''';
  }

  // Вспомогательные методы

  static String _generateEmptyDataPrompt(String type) {
    return '''
${"prompts.ai_empty_data_prompt".tr().replaceAll('{type}', type)}

СФОРМАТИРУЙ ОТВЕТ В ВИДЕ JSON:
{
  "title": "Начните отслеживать настроение",
  "description": "Добавьте несколько записей, чтобы получить персонализированные $type",
  "emoji": "🌟",
  "accentColor": "#4ECDC4",
  "suggestions": ["Добавьте первую запись настроения", "Попробуйте отслеживать настроение каждый день"]
}
''';
  }

  static String _calculateMoodTrend(List<MoodEntry> moods) {
    if (moods.length < 2) return 'недостаточно данных';

    final firstHalf =
        moods
            .take(moods.length ~/ 2)
            .map((m) => m.moodValue)
            .reduce((a, b) => a + b) /
        (moods.length ~/ 2);
    final secondHalf =
        moods
            .skip(moods.length ~/ 2)
            .map((m) => m.moodValue)
            .reduce((a, b) => a + b) /
        (moods.length - moods.length ~/ 2);

    if (secondHalf > firstHalf + 0.3) return 'улучшается';
    if (secondHalf < firstHalf - 0.3) return 'ухудшается';
    return 'стабильное';
  }

  static String _analyzeWeeklyPatterns(List<MoodEntry> moods) {
    final weekdayMoods = <int, List<int>>{};

    for (final mood in moods) {
      final weekday = mood.createdAt.weekday;
      weekdayMoods.putIfAbsent(weekday, () => []).add(mood.moodValue);
    }

    final weekdayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final patterns = weekdayMoods.entries
        .map((entry) {
          final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
          return '${weekdayNames[entry.key - 1]}: ${avg.toStringAsFixed(1)}/5';
        })
        .join(', ');

    return patterns.isEmpty ? 'недостаточно данных' : patterns;
  }

  static String _analyzeMonthlyTrends(List<MoodEntry> moods) {
    if (moods.length < 7) return 'недостаточно данных для анализа трендов';

    final firstWeek =
        moods.take(7).map((m) => m.moodValue).reduce((a, b) => a + b) / 7;
    final lastWeek =
        moods
            .skip(moods.length - 7)
            .map((m) => m.moodValue)
            .reduce((a, b) => a + b) /
        7;

    final change = lastWeek - firstWeek;
    if (change > 0.5)
      return 'значительное улучшение (+${change.toStringAsFixed(1)})';
    if (change < -0.5)
      return 'снижение настроения (${change.toStringAsFixed(1)})';
    return 'стабильные показатели';
  }

  static String _generateMoodStatistics(List<MoodEntry> moods) {
    if (moods.isEmpty) return 'нет данных';

    final values = moods.map((m) => m.moodValue).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return 'Среднее: ${avg.toStringAsFixed(1)}/5, Диапазон: $min-$max/5';
  }

  static String _calculateStressLevel(List<MoodEntry> moods) {
    if (moods.isEmpty) return 'неизвестно';

    final lowMoods = moods.where((m) => m.moodValue <= 2).length;
    final stressPercentage = (lowMoods / moods.length * 100).round();

    if (stressPercentage > 40) return 'высокий';
    if (stressPercentage > 20) return 'средний';
    return 'низкий';
  }

  static String _getRelaxationNeed(double avgMood, String stressLevel) {
    if (avgMood <= 2.5 || stressLevel == 'высокий') return 'высокая';
    if (avgMood <= 3.5 || stressLevel == 'средний') return 'средняя';
    return 'низкая';
  }

  /// Генерирует персонализированный промпт с учетом данных профиля пользователя
  static String generatePersonalizedPrompt(
    String basePrompt,
    UserProfileEntity profile,
    List<MoodEntry> moods,
  ) {
    final age = profile.age > 0 ? '${profile.age} лет' : 'возраст не указан';
    final interests = profile.interests.isNotEmpty
        ? profile.interests.join(', ')
        : 'интересы не указаны';
    final goals = profile.mentalHealthGoals.isNotEmpty
        ? profile.mentalHealthGoals.keys.join(', ')
        : 'цели не указаны';

    final moodHistory = moods.isNotEmpty
        ? moods
              .map(
                (m) =>
                    '${m.createdAt.day}/${m.createdAt.month}: ${m.moodValue}/5 - ${m.note ?? 'без заметки'}',
              )
              .join('\n')
        : 'история настроений пуста';

    final averageMood = moods.isNotEmpty
        ? (moods.map((m) => m.moodValue).reduce((a, b) => a + b) / moods.length)
              .toStringAsFixed(1)
        : '0.0';

    return '''
$basePrompt

ПЕРСОНАЛЬНАЯ ИНФОРМАЦИЯ ПОЛЬЗОВАТЕЛЯ:
Имя: ${profile.name}
Возраст: $age
Интересы: $interests
Ментальные цели: $goals
Серия записей: ${profile.streakDays} дней подряд
Всего записей: ${profile.totalEntries}

ИСТОРИЯ НАСТРОЕНИЙ (последние ${moods.length} записей):
$moodHistory

СТАТИСТИКА:
Средний уровень настроения: $averageMood/5
Текущая серия: ${profile.streakDays} дней подряд

ИНСТРУКЦИИ ДЛЯ AI:
1. Используй имя пользователя для персонализации
2. Учитывай возраст и интересы в рекомендациях
3. Ссылайся на ментальные цели пользователя
4. Анализируй паттерны в истории настроений
5. Предлагай практические советы с учетом интересов
6. Поддерживай мотивацию к продолжению серии записей
7. Отвечай на русском языке
8. Будь поддерживающим и эмпатичным
''';
  }

  /// Генерирует промпт для благодарности с учетом профиля
  static String generatePersonalizedGratitudePrompt(
    UserProfileEntity profile,
    List<MoodEntry> recentMoods,
  ) {
    final basePrompt = '''
Ты — AI-ассистент для практики благодарности в приложении MindSpace.
Создай персонализированные подсказки для благодарности, учитывая профиль пользователя и его настроение.

ЦЕЛЬ: Помочь пользователю развить привычку благодарности и улучшить психическое благополучие.

ФОРМАТ ОТВЕТА:
[Заголовок практики благодарности]

[3-5 персонализированных подсказки для благодарности]

[Краткая мотивационная фраза]
''';

    return generatePersonalizedPrompt(basePrompt, profile, recentMoods);
  }

  /// Генерирует промпт для медитации с учетом профиля
  static String generatePersonalizedMeditationPrompt(
    UserProfileEntity profile,
    List<MoodEntry> recentMoods,
  ) {
    final basePrompt = '''
Ты — AI-ассистент для медитации в приложении MindSpace.
Предложи персонализированную медитационную практику, учитывая текущее состояние пользователя.

ЦЕЛЬ: Помочь пользователю найти подходящую медитацию для текущего момента.

ФОРМАТ ОТВЕТА:
[Название медитации]

[Описание практики и её пользы]

[Инструкции по выполнению (3-5 шагов)]

[Длительность и сложность]

[Советы для лучшего результата]
''';

    return generatePersonalizedPrompt(basePrompt, profile, recentMoods);
  }
}
