class UserProfileEntity {
  final String id;
  final String name;
  final String? email;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;
  final String? bio;
  final List<String> interests;
  final Map<String, dynamic> mentalHealthGoals;
  final DateTime joinedDate;
  final int streakDays;
  final Map<String, dynamic> moodStatistics;
  final int totalEntries;
  final double averageMood;

  UserProfileEntity({
    required this.id,
    required this.name,
    this.email,
    this.dateOfBirth,
    this.profileImageUrl,
    this.bio,
    this.interests = const [],
    this.mentalHealthGoals = const {},
    required this.joinedDate,
    this.streakDays = 0,
    this.moodStatistics = const {},
    this.totalEntries = 0,
    this.averageMood = 0.0,
  });

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    return now.year -
        dateOfBirth!.year -
        (now.month < dateOfBirth!.month ||
                (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)
            ? 1
            : 0);
  }

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    String? bio,
    List<String>? interests,
    Map<String, dynamic>? mentalHealthGoals,
    DateTime? joinedDate,
    int? streakDays,
    Map<String, dynamic>? moodStatistics,
    int? totalEntries,
    double? averageMood,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      mentalHealthGoals: mentalHealthGoals ?? this.mentalHealthGoals,
      joinedDate: joinedDate ?? this.joinedDate,
      streakDays: streakDays ?? this.streakDays,
      moodStatistics: moodStatistics ?? this.moodStatistics,
      totalEntries: totalEntries ?? this.totalEntries,
      averageMood: averageMood ?? this.averageMood,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfileEntity(id: $id, name: $name, email: $email, age: $age, streakDays: $streakDays)';
  }
}
