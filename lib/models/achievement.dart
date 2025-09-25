class Achievement {
  final String id;
  final String habitId;
  final String title;
  final int requiredStreak;
  final int points;
  final bool achieved;

  Achievement({
    required this.id,
    required this.habitId,
    required this.title,
    required this.requiredStreak,
    required this.points,
    this.achieved = false,
  });

  Achievement copyWith({
    String? id,
    String? habitId,
    String? title,
    int? requiredStreak,
    int? points,
    bool? achieved,
  }) {
    return Achievement(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      requiredStreak: requiredStreak ?? this.requiredStreak,
      points: points ?? this.points,
      achieved: achieved ?? this.achieved,
    );
  }
}
