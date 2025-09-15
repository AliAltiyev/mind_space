class UserAchievementsModel {
  final List<AchievementModel> achievements;
  final int totalUnlocked;
  final int totalAchievements;

  UserAchievementsModel({
    required this.achievements,
    this.totalUnlocked = 0,
    this.totalAchievements = 0,
  });

  factory UserAchievementsModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementsModel(
      achievements: (json['achievements'] as List<dynamic>)
          .map((a) => AchievementModel.fromJson(a))
          .toList(),
      totalUnlocked: json['totalUnlocked'] ?? 0,
      totalAchievements: json['totalAchievements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'totalUnlocked': totalUnlocked,
    'totalAchievements': totalAchievements,
  };

  UserAchievementsModel copyWith({
    List<AchievementModel>? achievements,
    int? totalUnlocked,
    int? totalAchievements,
  }) {
    return UserAchievementsModel(
      achievements: achievements ?? this.achievements,
      totalUnlocked: totalUnlocked ?? this.totalUnlocked,
      totalAchievements: totalAchievements ?? this.totalAchievements,
    );
  }
}

class AchievementModel {
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

  AchievementModel({
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

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      unlocked: json['unlocked'] ?? false,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'])
          : null,
      progress: json['progress'] ?? 0,
      target: json['target'],
      category: json['category'] ?? 'general',
      rarity: json['rarity'] ?? 'common',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'unlocked': unlocked,
    'unlockedDate': unlockedDate?.toIso8601String(),
    'progress': progress,
    'target': target,
    'category': category,
    'rarity': rarity,
  };

  double get progressPercentage => progress / target;

  AchievementModel copyWith({
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
    return AchievementModel(
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
}
