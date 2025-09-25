import '../models/habit.dart';
import '../models/achievement.dart';

final mockHabits = [
  Habit(
    id: 'h1',
    name: 'Running',
    iconName: 'running',
    iconColorHex: '#C8B6FF',
    markerIcon: 'circle',
    markerColorHex: '#5F3DC4',
    reminderTime: DateTime.now(),
    targetDays: 30,
  ),
  Habit(
    id: 'h2',
    name: 'Meditation',
    iconName: 'meditation',
    iconColorHex: '#C8B6FF',
    markerIcon: 'cross',
    markerColorHex: '#D6336C',
    reminderTime: DateTime.now(),
    targetDays: 60,
  ),
  Habit(
    id: 'h3',
    name: 'Read',
    iconName: 'reading',
    iconColorHex: '#C8B6FF',
    markerIcon: 'check',
    markerColorHex: '#24B875',
    reminderTime: DateTime.now(),
    targetDays: 90,
  ),
];

final mockAchievements = [
  Achievement(id: 'a1', habitId: 'h1', title: '3 Days Streak', requiredStreak: 3, points: 5, achieved: true),
  Achievement(id: 'a2', habitId: 'h1', title: '7 Days Streak', requiredStreak: 7, points: 10),
  Achievement(id: 'a3', habitId: 'h2', title: '3 Days Streak', requiredStreak: 3, points: 5),
  Achievement(id: 'a4', habitId: 'h3', title: '3 Days Streak', requiredStreak: 3, points: 5, achieved: true),
];
