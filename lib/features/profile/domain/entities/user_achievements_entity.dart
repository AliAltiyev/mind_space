class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedDate;
  final int progress;
  final int target;
  final String category;
  final String rarity;

  AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedDate,
    this.progress = 0,
    required this.target,
    this.category = 'general',
    this.rarity = 'common',
  });

  double get progressPercentage => progress / target;

  bool get isCompleted => progress >= target;

  AchievementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    DateTime? unlockedDate,
    int? progress,
    int? target,
    String? category,
    String? rarity,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AchievementEntity(id: $id, title: $title, unlocked: $unlocked, progress: $progress/$target)';
  }
}

class UserAchievementsEntity {
  final List<AchievementEntity> achievements;
  final int totalUnlocked;
  final int totalAchievements;

  UserAchievementsEntity({
    this.achievements = const [],
    this.totalUnlocked = 0,
    this.totalAchievements = 0,
  });

  double get completionPercentage =>
      totalAchievements > 0 ? totalUnlocked / totalAchievements : 0.0;

  List<AchievementEntity> get unlockedAchievements =>
      achievements.where((a) => a.unlocked).toList();

  List<AchievementEntity> get lockedAchievements =>
      achievements.where((a) => !a.unlocked).toList();

  UserAchievementsEntity copyWith({
    List<AchievementEntity>? achievements,
    int? totalUnlocked,
    int? totalAchievements,
  }) {
    return UserAchievementsEntity(
      achievements: achievements ?? this.achievements,
      totalUnlocked: totalUnlocked ?? this.totalUnlocked,
      totalAchievements: totalAchievements ?? this.totalAchievements,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAchievementsEntity &&
        other.totalUnlocked == totalUnlocked &&
        other.totalAchievements == totalAchievements;
  }

  @override
  int get hashCode {
    return Object.hash(totalUnlocked, totalAchievements);
  }

  @override
  String toString() {
    return 'UserAchievementsEntity(totalUnlocked: $totalUnlocked, totalAchievements: $totalAchievements, completionPercentage: ${(completionPercentage * 100).toStringAsFixed(1)}%)';
  }
}
