// lib/models/achievement.dart
class Achievement {
  final String id;
  final String habitId;
  final String title;
  final int requiredStreak;
  final int points;
  bool achieved;
  final String medalAsset; // kept name `medalAsset` to match usages across project

  Achievement({
    required this.id,
    required this.habitId,
    required this.title,
    required this.requiredStreak,
    required this.points,
    this.achieved = false,
    required this.medalAsset,
  });

  Achievement copyWith({
    String? id,
    String? habitId,
    String? title,
    int? requiredStreak,
    int? points,
    bool? achieved,
    String? medalAsset,
  }) {
    return Achievement(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      requiredStreak: requiredStreak ?? this.requiredStreak,
      points: points ?? this.points,
      achieved: achieved ?? this.achieved,
      medalAsset: medalAsset ?? this.medalAsset,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id']?.toString() ?? '',
      habitId: json['habitId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      requiredStreak: (json['requiredStreak'] is int)
          ? json['requiredStreak'] as int
          : int.tryParse(json['requiredStreak']?.toString() ?? '0') ?? 0,
      points: (json['points'] is int)
          ? json['points'] as int
          : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      achieved: json['achieved'] == true,
      medalAsset: json['medalAsset']?.toString() ??
          json['medalIconAsset']?.toString() ??
          '',
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
      'medalAsset': medalAsset,
    };
  }
}
