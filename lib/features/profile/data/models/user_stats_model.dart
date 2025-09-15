class UserStatsModel {
  final int totalEntries;
  final int currentStreak;
  final int longestStreak;
  final double averageMood;
  final Map<String, int> moodDistribution;
  final Map<String, int> activityFrequency;
  final DateTime lastEntryDate;
  final Map<String, dynamic> weeklyStats;
  final Map<String, dynamic> monthlyStats;

  UserStatsModel({
    this.totalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageMood = 0.0,
    this.moodDistribution = const {},
    this.activityFrequency = const {},
    required this.lastEntryDate,
    this.weeklyStats = const {},
    this.monthlyStats = const {},
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalEntries: json['totalEntries'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      averageMood: (json['averageMood'] ?? 0).toDouble(),
      moodDistribution: Map<String, int>.from(json['moodDistribution'] ?? {}),
      activityFrequency: Map<String, int>.from(json['activityFrequency'] ?? {}),
      lastEntryDate: DateTime.parse(json['lastEntryDate']),
      weeklyStats: Map<String, dynamic>.from(json['weeklyStats'] ?? {}),
      monthlyStats: Map<String, dynamic>.from(json['monthlyStats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalEntries': totalEntries,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'averageMood': averageMood,
    'moodDistribution': moodDistribution,
    'activityFrequency': activityFrequency,
    'lastEntryDate': lastEntryDate.toIso8601String(),
    'weeklyStats': weeklyStats,
    'monthlyStats': monthlyStats,
  };

  UserStatsModel copyWith({
    int? totalEntries,
    int? currentStreak,
    int? longestStreak,
    double? averageMood,
    Map<String, int>? moodDistribution,
    Map<String, int>? activityFrequency,
    DateTime? lastEntryDate,
    Map<String, dynamic>? weeklyStats,
    Map<String, dynamic>? monthlyStats,
  }) {
    return UserStatsModel(
      totalEntries: totalEntries ?? this.totalEntries,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      averageMood: averageMood ?? this.averageMood,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      activityFrequency: activityFrequency ?? this.activityFrequency,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }
}
