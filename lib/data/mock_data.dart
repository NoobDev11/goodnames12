import '../models/habit.dart' as habit_model;
import '../models/achievement.dart' as achievement_model;

final List<habit_model.Habit> mockHabits = [
  habit_model.Habit(
    id: 'h1',
    name: 'Running',
    iconName: 'running',
    iconColorHex: '#C8B6FF',
    markerIcon: 'circle',
    markerColorHex: '#5F3DC4',
    reminderTime: DateTime.now(),
    targetDays: 30,
    medalAsset: 'assets/icon/medal_custom_days.png',
  ),
  habit_model.Habit(
    id: 'h2',
    name: 'Meditation',
    iconName: 'meditation',
    iconColorHex: '#C8B6FF',
    markerIcon: 'cross',
    markerColorHex: '#D6336C',
    reminderTime: DateTime.now(),
    targetDays: 60,
    medalAsset: 'assets/icon/medal_custom_days.png',
  ),
  habit_model.Habit(
    id: 'h3',
    name: 'Read',
    iconName: 'reading',
    iconColorHex: '#C8B6FF',
    markerIcon: 'check',
    markerColorHex: '#24B875',
    reminderTime: DateTime.now(),
    targetDays: 90,
    medalAsset: 'assets/icon/medal_custom_days.png',
  ),
];

final List<achievement_model.Achievement> mockAchievements = [
  achievement_model.Achievement(
      id: 'a1', habitId: 'h1', title: '3 Days Streak', requiredStreak: 3, points: 5, achieved: true),
  achievement_model.Achievement(
      id: 'a2', habitId: 'h1', title: '7 Days Streak', requiredStreak: 7, points: 10),
  achievement_model.Achievement(
      id: 'a3', habitId: 'h2', title: '3 Days Streak', requiredStreak: 3, points: 5),
  achievement_model.Achievement(
      id: 'a4', habitId: 'h3', title: '3 Days Streak', requiredStreak: 3, points: 5, achieved: true),
];
