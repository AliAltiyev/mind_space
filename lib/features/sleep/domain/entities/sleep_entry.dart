/// Модель записи сна
class SleepEntry {
  final int? id;
  final DateTime sleepStart; // Время засыпания
  final DateTime sleepEnd; // Время пробуждения
  final int durationMinutes; // Продолжительность сна в минутах
  final int quality; // Качество сна (1-5)
  final String? note; // Заметки
  final List<String>
  factors; // Факторы, влияющие на сон (кофе, стресс, упражнения и т.д.)
  final DateTime createdAt;
  final DateTime updatedAt;

  SleepEntry({
    this.id,
    required this.sleepStart,
    required this.sleepEnd,
    required this.durationMinutes,
    required this.quality,
    this.note,
    this.factors = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Вычисляет продолжительность сна автоматически
  factory SleepEntry.create({
    int? id,
    required DateTime sleepStart,
    required DateTime sleepEnd,
    required int quality,
    String? note,
    List<String> factors = const [],
  }) {
    final duration = sleepEnd.difference(sleepStart).inMinutes;
    final now = DateTime.now();
    return SleepEntry(
      id: id,
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
      durationMinutes: duration,
      quality: quality,
      note: note,
      factors: factors,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sleepStart': sleepStart.toIso8601String(),
      'sleepEnd': sleepEnd.toIso8601String(),
      'durationMinutes': durationMinutes,
      'quality': quality,
      'note': note,
      'factors': factors.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'],
      sleepStart: DateTime.parse(map['sleepStart']),
      sleepEnd: DateTime.parse(map['sleepEnd']),
      durationMinutes: map['durationMinutes'] ?? 0,
      quality: map['quality'] ?? 3,
      note: map['note'],
      factors: map['factors'] != null && map['factors'].toString().isNotEmpty
          ? map['factors'].toString().split(',')
          : [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  SleepEntry copyWith({
    int? id,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    int? durationMinutes,
    int? quality,
    String? note,
    List<String>? factors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      sleepStart: sleepStart ?? this.sleepStart,
      sleepEnd: sleepEnd ?? this.sleepEnd,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      factors: factors ?? this.factors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Получить продолжительность в часах и минутах
  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '$hoursч $minutesм';
  }

  /// Получить среднее качество сна за период
  static double getAverageQuality(List<SleepEntry> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.map((e) => e.quality).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  /// Получить среднюю продолжительность сна за период
  static double getAverageDuration(List<SleepEntry> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.map((e) => e.durationMinutes).reduce((a, b) => a + b);
    return sum / entries.length;
  }
}

/// Качество сна
enum SleepQuality {
  veryPoor(1, 'Очень плохо'),
  poor(2, 'Плохо'),
  fair(3, 'Средне'),
  good(4, 'Хорошо'),
  excellent(5, 'Отлично');

  final int value;
  final String label;

  const SleepQuality(this.value, this.label);

  static SleepQuality fromValue(int value) {
    return SleepQuality.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SleepQuality.fair,
    );
  }
}

/// Факторы, влияющие на сон
enum SleepFactor {
  coffee('Кофе/кофеин'),
  alcohol('Алкоголь'),
  stress('Стресс'),
  exercise('Физические упражнения'),
  screenTime('Время перед экраном'),
  lateMeal('Поздний прием пищи'),
  noise('Шум'),
  temperature('Температура'),
  medication('Лекарства'),
  anxiety('Тревога');

  final String label;

  const SleepFactor(this.label);
}


