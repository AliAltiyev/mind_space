// Простая реализация базы данных для демонстрации архитектуры

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
  // Простая реализация без SQLite для демонстрации архитектуры
  final Map<String, String> _settings = {};
  final List<MoodEntry> _moodEntries = [];
  final List<AiInsight> _aiInsights = [];

  Future<void> initialize() async {
    // Инициализация базы данных
  }

  /// Получение настроек по ключу
  Future<String?> getSetting(String key) async {
    return _settings[key];
  }

  /// Сохранение настройки
  Future<void> setSetting(String key, String value) async {
    _settings[key] = value;
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
    print(
      '✅ Запись настроения добавлена: ${entry.moodValue}/5 - ${entry.note ?? "без заметки"}',
    );
  }

  /// Получение всех записей настроения
  Future<List<MoodEntry>> getAllMoodEntries() async {
    return List.from(_moodEntries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
