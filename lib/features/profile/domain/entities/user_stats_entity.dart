class UserStatsEntity {
  final int totalEntries;
  final int currentStreak;
  final int longestStreak;
  final double averageMood;
  final Map<String, int> moodDistribution;
  final Map<String, int> activityFrequency;
  final DateTime lastEntryDate;
  final Map<String, dynamic> weeklyStats;
  final Map<String, dynamic> monthlyStats;

  UserStatsEntity({
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

  UserStatsEntity copyWith({
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
    return UserStatsEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStatsEntity &&
        other.totalEntries == totalEntries &&
        other.currentStreak == currentStreak &&
        other.averageMood == averageMood &&
        other.lastEntryDate == lastEntryDate;
  }

  @override
  int get hashCode {
    return Object.hash(totalEntries, currentStreak, averageMood, lastEntryDate);
  }

  @override
  String toString() {
    return 'UserStatsEntity(totalEntries: $totalEntries, currentStreak: $currentStreak, longestStreak: $longestStreak, averageMood: $averageMood)';
  }
}
