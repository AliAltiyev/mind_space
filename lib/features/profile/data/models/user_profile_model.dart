class UserProfileModel {
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

  UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      mentalHealthGoals: Map<String, dynamic>.from(
        json['mentalHealthGoals'] ?? {},
      ),
      joinedDate: DateTime.parse(json['joinedDate']),
      streakDays: json['streakDays'] ?? 0,
      moodStatistics: Map<String, dynamic>.from(json['moodStatistics'] ?? {}),
      totalEntries: json['totalEntries'] ?? 0,
      averageMood: (json['averageMood'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'interests': interests,
    'mentalHealthGoals': mentalHealthGoals,
    'joinedDate': joinedDate.toIso8601String(),
    'streakDays': streakDays,
    'moodStatistics': moodStatistics,
    'totalEntries': totalEntries,
    'averageMood': averageMood,
  };

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

  UserProfileModel copyWith({
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
    return UserProfileModel(
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
}
