import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/ai_insight_entity.dart';
import '../../domain/entities/gratitude_entity.dart';
import '../../domain/entities/meditation_entity.dart';
import '../../domain/entities/mood_pattern_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_local_datasource.dart';
import '../datasources/groq_datasource.dart';
import '../models/ai_insight_model.dart';
import '../models/gratitude_suggestion_model.dart';
import '../models/meditation_session_model.dart';
import '../models/mood_pattern_model.dart';

/// Реализация AI репозитория
class AIRepositoryImpl implements AIRepository {
  final GroqDataSource _remoteDataSource;
  final AILocalDataSource _localDataSource;

  AIRepositoryImpl({
    required GroqDataSource remoteDataSource,
    required AILocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<AIInsightEntity> getMoodInsights(List<MoodEntry> entries) async {
    try {
      final cacheKey = 'insights_${entries.length}_${entries.hashCode}';

      // Проверяем кэш
      final cached = await _localDataSource.getCachedResponse(cacheKey);
      if (cached != null) {
        print('📦 Используем кэшированный инсайт');
        return AIInsightModel.fromJson(cached).toEntity();
      }

      // Получаем данные от API
      print('🌐 Запрашиваем инсайт от AI');
      final response = await _remoteDataSource.getMoodInsights(entries);

      final insight = AIInsightModel.fromJson(response);

      // Кэшируем результат
      await _localDataSource.cacheAIResponse(cacheKey, insight.toMap());

      return insight.toEntity();
    } catch (e) {
      print('❌ Ошибка получения AI инсайтов: $e');

      // Возвращаем fallback инсайт
      return _createFallbackInsight(entries);
    }
  }

  @override
  Future<MoodPatternEntity> analyzeMoodPatterns(
    List<MoodEntry> moodHistory,
  ) async {
    try {
      final cacheKey = 'patterns_${moodHistory.length}_${moodHistory.hashCode}';

      // Проверяем кэш
      final cached = await _localDataSource.getCachedResponse(cacheKey);
      if (cached != null) {
        print('📦 Используем кэшированный анализ паттернов');
        return MoodPatternModel.fromJson(cached).toEntity();
      }

      // Получаем данные от API
      print('🌐 Запрашиваем анализ паттернов от AI');
      final response = await _remoteDataSource.analyzeMoodPatterns(moodHistory);

      final patterns = MoodPatternModel.fromJson(
        response,
      ).copyWith(analysisPeriod: moodHistory.length);

      // Кэшируем результат
      await _localDataSource.cacheAIResponse(cacheKey, patterns.toMap());

      return patterns.toEntity();
    } catch (e) {
      print('❌ Ошибка анализа паттернов: $e');

      // Возвращаем fallback анализ
      return _createFallbackPatternAnalysis(moodHistory);
    }
  }

  @override
  Future<GratitudeEntity> generateGratitudePrompts(
    List<MoodEntry> recentMoods,
  ) async {
    try {
      final cacheKey = 'gratitude_${recentMoods.length}_${DateTime.now().day}';

      // Проверяем кэш (обновляем ежедневно)
      final cached = await _localDataSource.getCachedResponse(cacheKey);
      if (cached != null) {
        print('📦 Используем кэшированные благодарственные предложения');
        return GratitudeSuggestionModel.fromJson(cached).toEntity();
      }

      // Получаем данные от API
      print('🌐 Запрашиваем благодарственные предложения от AI');
      final response = await _remoteDataSource.generateGratitudePrompts(
        recentMoods,
      );

      final gratitude = GratitudeSuggestionModel.fromJson(response);

      // Кэшируем результат
      await _localDataSource.cacheAIResponse(cacheKey, gratitude.toMap());

      return gratitude.toEntity();
    } catch (e) {
      print('❌ Ошибка генерации благодарственных предложений: $e');

      // Возвращаем fallback предложения
      return _createFallbackGratitudePrompts();
    }
  }

  @override
  Future<MeditationEntity> suggestMeditationSession(
    List<MoodEntry> recentMoods,
  ) async {
    try {
      final cacheKey =
          'meditation_${recentMoods.length}_${DateTime.now().hour}';

      // Проверяем кэш (обновляем каждый час)
      final cached = await _localDataSource.getCachedResponse(cacheKey);
      if (cached != null) {
        print('📦 Используем кэшированную медитацию');
        return MeditationSessionModel.fromJson(cached).toEntity();
      }

      // Получаем данные от API
      print('🌐 Запрашиваем медитацию от AI');
      final response = await _remoteDataSource.suggestMeditationSession(
        recentMoods,
      );

      final meditation = MeditationSessionModel.fromJson(response);

      // Кэшируем результат
      await _localDataSource.cacheAIResponse(cacheKey, meditation.toMap());

      return meditation.toEntity();
    } catch (e) {
      print('❌ Ошибка предложения медитации: $e');

      // Возвращаем fallback медитацию
      return _createFallbackMeditationSession();
    }
  }

  @override
  Future<void> cacheAIResponse(String key, dynamic response) async {
    await _localDataSource.cacheAIResponse(key, response);
  }

  @override
  Future<dynamic> getCachedResponse(String key) async {
    return await _localDataSource.getCachedResponse(key);
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  @override
  Future<bool> isAIServiceAvailable() async {
    try {
      return await _remoteDataSource.isServiceAvailable();
    } catch (e) {
      print('❌ AI сервис недоступен: $e');
      return false;
    }
  }

  // Fallback методы

  AIInsightEntity _createFallbackInsight(List<MoodEntry> entries) {
    final averageMood = entries.isNotEmpty
        ? entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
              entries.length
        : 3.0;

    String title;
    String description;
    String emoji;
    Color accentColor;
    List<String> suggestions;

    if (averageMood >= 4) {
      title = 'Отличное настроение!';
      description =
          'Вы поддерживаете высокий уровень благополучия. Продолжайте в том же духе!';
      emoji = '🌟';
      accentColor = const Color(0xFF6BCF7F);
      suggestions = [
        'Поделитесь позитивом с окружающими',
        'Зафиксируйте, что делает вас счастливым',
      ];
    } else if (averageMood <= 2) {
      title = 'Трудные времена';
      description =
          'Каждый испытывает сложные периоды. Это нормально и временно.';
      emoji = '🤗';
      accentColor = const Color(0xFFFD79A8);
      suggestions = [
        'Обратитесь за поддержкой к близким',
        'Попробуйте дыхательные упражнения',
      ];
    } else {
      title = 'Стабильное состояние';
      description =
          'Ваше настроение находится в хорошем балансе. Это отличная основа для дальнейшего развития.';
      emoji = '⚖️';
      accentColor = const Color(0xFFA8E6CF);
      suggestions = [
        'Попробуйте новые активности',
        'Ведите дневник благодарности',
      ];
    }

    return AIInsightEntity(
      title: title,
      description: description,
      emoji: emoji,
      accentColor: accentColor,
      suggestions: suggestions,
      createdAt: DateTime.now(),
      confidence: 0.8,
    );
  }

  MoodPatternEntity _createFallbackPatternAnalysis(
    List<MoodEntry> moodHistory,
  ) {
    return MoodPatternEntity(
      title: 'Анализ паттернов',
      description:
          'На основе ваших записей можно заметить интересные тенденции в настроении.',
      emoji: '📊',
      accentColor: const Color(0xFF74B9FF),
      patterns: [
        'Регулярность в отслеживании настроения',
        'Влияние времени дня на настроение',
      ],
      recommendations: [
        'Продолжайте отслеживать настроение',
        'Обратите внимание на факторы, влияющие на настроение',
      ],
      analyzedAt: DateTime.now(),
      analysisPeriod: moodHistory.length,
    );
  }

  GratitudeEntity _createFallbackGratitudePrompts() {
    return GratitudeEntity(
      title: 'Практика благодарности',
      description:
          'Благодарность помогает улучшить настроение и общее самочувствие.',
      emoji: '🙏',
      accentColor: const Color(0xFFFFD93D),
      prompts: [
        'За что я благодарен сегодня?',
        'Кто из людей сделал мой день лучше?',
        'Какие простые радости я испытал?',
        'За какие достижения я могу себя похвалить?',
        'Что в природе меня восхищает?',
      ],
      createdAt: DateTime.now(),
      category: GratitudeCategory.general,
    );
  }

  MeditationEntity _createFallbackMeditationSession() {
    return MeditationEntity(
      title: 'Медитация осознанности',
      description:
          'Простая практика для расслабления и восстановления внутреннего баланса.',
      emoji: '🧘',
      accentColor: const Color(0xFF74B9FF),
      type: MeditationType.mindfulness,
      duration: 10,
      instructions: [
        'Сядьте удобно и закройте глаза',
        'Сосредоточьтесь на дыхании',
        'Наблюдайте за мыслями без суждения',
      ],
      tips: [
        'Начните с 5 минут и постепенно увеличивайте время',
        'Не расстраивайтесь, если мысли отвлекают',
      ],
      createdAt: DateTime.now(),
      difficulty: MeditationDifficulty.beginner,
    );
  }
}
