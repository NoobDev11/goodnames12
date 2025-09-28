class Achievement {
  final String id;
  final String habitId;
  final String title;
  final int requiredStreak;
  final int points;
  bool achieved;
  final String medalIconAsset;

  Achievement({
    required this.id,
    required this.habitId,
    required this.title,
    required this.requiredStreak,
    required this.points,
    this.achieved = false,
    this.medalIconAsset = '',
  });

  Achievement copyWith({
    String? id,
    String? habitId,
    String? title,
    int? requiredStreak,
    int? points,
    bool? achieved,
    String? medalIconAsset,
  }) {
    return Achievement(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      requiredStreak: requiredStreak ?? this.requiredStreak,
      points: points ?? this.points,
      achieved: achieved ?? this.achieved,
      medalIconAsset: medalIconAsset ?? this.medalIconAsset,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      title: json['title'] as String,
      requiredStreak: json['requiredStreak'] as int,
      points: json['points'] as int,
      achieved: json['achieved'] as bool? ?? false,
      medalIconAsset: json['medalIconAsset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'title': title,
      'requiredStreak': requiredStreak,
      'points': points,
      'achieved': achieved,
      'medalIconAsset': medalIconAsset,
    };
  }
}
