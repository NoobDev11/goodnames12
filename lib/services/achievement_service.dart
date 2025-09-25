import '../models/achievement.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();

  factory AchievementService() {
    return _instance;
  }

  AchievementService._internal();

  final List<Achievement> _achievements = [];

  List<Achievement> get achievements => List.unmodifiable(_achievements);

  void addAchievement(Achievement achievement) {
    _achievements.add(achievement);
  }

  List<Achievement> getAchievementsForHabit(String habitId) {
    return _achievements.where((a) => a.habitId == habitId).toList();
  }

  void markAchievementCompleted(String achievementId) {
    int index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index >= 0) {
      _achievements[index] = Achievement(
        id: _achievements[index].id,
        habitId: _achievements[index].habitId,
        title: _achievements[index].title,
        points: _achievements[index].points,
        requiredStreak: _achievements[index].requiredStreak,
        achieved: true,
      );
    }
  }
}
