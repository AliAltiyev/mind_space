import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

// Реализация базы данных с локальным сохранением

/// Модель настроения
class MoodEntry {
  final int? id;
  final int moodValue;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodEntry({
    this.id,
    required this.moodValue,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moodValue': moodValue,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      moodValue: map['moodValue'],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Модель ИИ-инсайта
class AiInsight {
  final int? id;
  final String title;
  final String description;
  final String type;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  AiInsight({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AiInsight.fromMap(Map<String, dynamic> map) {
    return AiInsight(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      confidence: map['confidence'].toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

/// Основная база данных приложения
class AppDatabase {
  SharedPreferences? _prefs;
  final Map<String, String> _settings = {};
  final List<MoodEntry> _moodEntries = [];
  final List<AiInsight> _aiInsights = [];

  // Ключи для SharedPreferences
  static const String _moodEntriesKey = 'mood_entries';
  static const String _aiInsightsKey = 'ai_insights';
  static const String _settingsKey = 'settings';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  /// Загрузка данных из локального хранилища
  Future<void> _loadData() async {
    if (_prefs == null) return;

    // Загружаем записи настроения
    final moodEntriesJson = _prefs!.getStringList(_moodEntriesKey) ?? [];
    _moodEntries.clear();
    for (final json in moodEntriesJson) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _moodEntries.add(MoodEntry.fromMap(map));
      } catch (e) {
        print('database.error_loading_mood_entry'.tr(namedArgs: {'error': e.toString()}));
      }
    }

    // Загружаем AI инсайты
    final aiInsightsJson = _prefs!.getStringList(_aiInsightsKey) ?? [];
    _aiInsights.clear();
    for (final json in aiInsightsJson) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _aiInsights.add(AiInsight.fromMap(map));
      } catch (e) {
        print('database.error_loading_ai_insight'.tr(namedArgs: {'error': e.toString()}));
      }
    }

    // Загружаем настройки
    final settingsJson = _prefs!.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final map = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings.addAll(Map<String, String>.from(map));
      } catch (e) {
        print('database.error_loading_settings'.tr(namedArgs: {'error': e.toString()}));
      }
    }

    print('✅ Данные загружены: ${_moodEntries.length} записей настроения, ${_aiInsights.length} AI инсайтов');
  }

  /// Сохранение данных в локальное хранилище
  Future<void> _saveData() async {
    if (_prefs == null) return;

    try {
      // Сохраняем записи настроения
      final moodEntriesJson = _moodEntries.map((entry) => jsonEncode(entry.toMap())).toList();
      await _prefs!.setStringList(_moodEntriesKey, moodEntriesJson);

      // Сохраняем AI инсайты
      final aiInsightsJson = _aiInsights.map((insight) => jsonEncode(insight.toMap())).toList();
      await _prefs!.setStringList(_aiInsightsKey, aiInsightsJson);

      // Сохраняем настройки
      await _prefs!.setString(_settingsKey, jsonEncode(_settings));

      print('💾 Данные сохранены локально');
    } catch (e) {
      print('database.error_saving_data'.tr(namedArgs: {'error': e.toString()}));
    }
  }

  /// Получение настроек по ключу
  Future<String?> getSetting(String key) async {
    return _settings[key];
  }

  /// Сохранение настройки
  Future<void> setSetting(String key, String value) async {
    _settings[key] = value;
    await _saveData();
  }

  /// Получение настроений за период
  Future<List<MoodEntry>> getMoodsForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    return _moodEntries
        .where(
          (entry) =>
              entry.createdAt.isAfter(start) && entry.createdAt.isBefore(end),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Получение последнего настроения
  Future<MoodEntry?> getLastMood() async {
    if (_moodEntries.isEmpty) return null;

    _moodEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _moodEntries.first;
  }

  /// Получение ИИ-инсайтов по типу
  Future<List<AiInsight>> getInsightsByType(String type) async {
    return _aiInsights.where((insight) => insight.type == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Добавление новой записи настроения
  Future<void> addMoodEntry(MoodEntry entry) async {
    _moodEntries.add(entry);
    await _saveData(); // Сохраняем данные локально
    print(
      'database.mood_entry_added'.tr().replaceAll('{mood}', '${entry.moodValue}/5').replaceAll('{note}', entry.note ?? 'database.no_note'.tr()).replaceAll('{date}', '${entry.createdAt}'),
    );
  }

  /// Получение всех записей настроения
  Future<List<MoodEntry>> getAllMoodEntries() async {
    return List.from(_moodEntries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Добавление нового AI инсайта
  Future<void> addAiInsight(AiInsight insight) async {
    _aiInsights.add(insight);
    await _saveData(); // Сохраняем данные локально
    print(
      '✅ AI инсайт добавлен: ${insight.title} - ${insight.type}',
    );
  }

  /// Получение всех AI инсайтов
  Future<List<AiInsight>> getAllAiInsights() async {
    return List.from(_aiInsights)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Очистка всех данных (для отладки)
  Future<void> clearAllData() async {
    _moodEntries.clear();
    _aiInsights.clear();
    _settings.clear();
    await _saveData();
    print('🗑️ Все данные очищены');
  }
}
