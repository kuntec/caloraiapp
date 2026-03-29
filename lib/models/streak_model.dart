class Streak {
  final String streakType;
  final int currentStreak;
  final int longestStreak;

  Streak({
    required this.streakType,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      streakType: json['streakType'],
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }
}
