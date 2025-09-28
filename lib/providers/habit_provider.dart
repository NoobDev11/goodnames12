import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/achievement.dart';
import '../data/local_storage.dart';
import 'habit_stats_provider.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Habit> _habits = [];
  final Map<String, bool> _habitCompletedToday = {};

  final HabitStatsProvider statsProvider;

  HabitProvider(this.statsProvider) {
    _init();
  }

  Future<void> _init() async {
    await _notificationService.init();
    await _loadHabits();
    await _loadHabitToday();
  }

  List<Habit> get habits => _habits;

  Habit? getHabit(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadHabits() async {
    final jsonString = await LocalStorage.instance.getString('habits');
    if (jsonString != null) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _habits = jsonList.map((json) {
          final parsedHabit = Habit.fromJson(json);
          List<Achievement> achievements = [];
          if (json['achievements'] != null) {
            final achievementsJson = json['achievements'] as List?;
            if (achievementsJson != null) {
              achievements = achievementsJson.map((e) => Achievement.fromJson(e)).toList();
            }
          }
          return parsedHabit.copyWith(achievements: achievements);
        }).toList();

        for (int i = 0; i < _habits.length; i++) {
          final ach = _habits[i].achievements;
          if (ach == null || ach.isEmpty) {
            _habits[i] = _habits[i].copyWith(
                achievements: _initDefaultAchievements(_habits[i].targetDays));
            await _scheduleNotificationForHabit(_habits[i]);
          }
        }
      } catch (_) {
        _habits = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    final jsonList = _habits.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await LocalStorage.instance.setString('habits', jsonString);
  }

  Future<void> addHabit(Habit habit) async {
    final ach = habit.achievements;
    Habit habitWithAchievements =
        (ach == null || ach.isEmpty) ? habit.copyWith(achievements: _initDefaultAchievements(habit.targetDays)) : habit;

    _habits.add(habitWithAchievements);
    await _saveHabits();
    await _scheduleNotificationForHabit(habitWithAchievements);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    final ach = habit.achievements;
    Habit habitWithAchievements = (ach == null || ach.isEmpty)
        ? habit.copyWith(achievements: _initDefaultAchievements(habit.targetDays))
        : habit;

    final index = _habits.indexOf(habit);
    if (index != -1) {
      _habits[index] = habitWithAchievements;
      await _saveHabits();
      await _scheduleNotificationForHabit(habitWithAchievements);
      notifyListeners();
    }
  }

  Future<void> removeHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    _habitCompletedToday.remove(id);
    await _saveHabits();
    await _saveHabitToday();
    await _notificationService.cancel(_notificationId(id));
    notifyListeners();
  }

  Future<void> _loadHabitToday() async {
    final jsonString = await LocalStorage.instance.getString('habitCompletedToday');
    if (jsonString == null) {
      notifyListeners();
      return;
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      _habitCompletedToday.clear();
      map.forEach((key, value) {
        _habitCompletedToday[key] = value as bool;
      });
    } catch (_) {
      _habitCompletedToday.clear();
    }
    notifyListeners();
  }

  Future<void> _saveHabitToday() async {
    final jsonString = jsonEncode(_habitCompletedToday);
    await LocalStorage.instance.setString('habitCompletedToday', jsonString);
  }

  void toggleHabitCompleted(String id) {
    final isCompleted = _habitCompletedToday[id] ?? false;
    _habitCompletedToday[id] = !isCompleted;
    _saveHabitToday();
    notifyListeners();

    statsProvider.markDone?.call(id, DateTime.now(), !isCompleted);

    final habit = getHabit(id);
    if (habit == null) return;

    bool updated = false;
    List<Achievement> updatedAchievements = habit.achievements?.map((a) => a.copyWith())?.toList() ?? [];

    for (int i = 0; i < updatedAchievements.length; i++) {
      final ach = updatedAchievements[i];
      if (achieved == false &&
          (statsProvider.currentStreak?.call(id) ?? 0) >= ach.requiredStreak) {
        updatedAchievements[i] = ach.copyWith(achieved: true);
        updated = true;
      }
    }
    if (updated) {
      final updatedHabit = habit.copyWith(achievements: updatedAchievements);
      saveHabits(updatedHabit);
    }
  }

  Future<void> saveHabits(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) return;
    _habits[index] = habit;
    await _saveHabits();
    notifyListeners();
  }

  bool isHabitCompletedToday(String id) {
    return _habitCompletedToday[id] ?? false;
  }

  int _notificationId(String id) {
    return id.hashCode & 0x7FFFFFFF;
  }

  Future<void> _scheduleNotificationForHabit(Habit habit) async {
    if (habit.reminderTime == null) {
      await _notificationService.cancel(_notificationId(habit.id));
      return;
    }
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, habit.reminderTime!.hour, habit.reminderTime!.minute);
    if (scheduledTime.isBefore(now)) scheduledTime = scheduledTime.add(Duration(days: 1));
    await _notificationService.scheduleNotification(
      _notificationId(habit.id),
      'Time for your habit!',
      'Don\'t forget to complete "${habit.name}" today.',
      scheduledTime,
    );
  }

  void importHabits(List<Habit> habits) {
    _habits = habits;
    notifyListeners();
    _saveHabits();
  }

  List<Achievement> _initDefaultAchievements(int? customTarget) {
    final milestones = <Achievement>[
      Achievement(
        id: '1',
        title: '3 Days',
        requiredStreak: 3,
        points: 5,
        achieved: false,
        medalAsset: 'assets/icon/medal_3_days.png',
      ),
      Achievement(
        id: '2',
        title: '7 Days',
        requiredStreak: 7,
        points: 10,
        achieved: false,
        medalAsset: 'assets/icon/medal_7_days.png',
      ),
      Achievement(
        id: '3',
        title: '15 Days',
        requiredStreak: 15,
        points: 15,
        achieved: false,
        medalAsset: 'assets/icon/medal_15_days.png',
      ),
      Achievement(
        id: '4',
        title: '30 Days',
        requiredStreak: 30,
        points: 20,
        achieved: false,
        medalAsset: 'assets/icon/medal_30_days.png',
      ),
      Achievement(
        id: '5',
        title: '60 Days',
        requiredStreak: 60,
        points: 30,
        achieved: false,
        medalAsset: 'assets/icon/medal_60_days.png',
      ),
      Achievement(
        id: '6',
        title: '90 Days',
        requiredStreak: 90,
        points: 50,
        achieved: false,
        medalAsset: 'assets/icon/medal_90_days.png',
      ),
      Achievement(
        id: '7',
        title: '180 Days',
        requiredStreak: 180,
        points: 75,
        achieved: false,
        medalAsset: 'assets/icon/medal_180_days.png',
      ),
      Achievement(
        id: '8',
        title: '365 Days',
        requiredStreak: 365,
        points: 100,
        achieved: false,
        medalAsset: 'assets/icon/medal_365_days.png',
      ),
    ];

    if (customTarget != null && customTarget > 0) {
      milestones.add(
        Achievement(
          id: 'custom',
          title: 'Custom Target',
          requiredStreak: customTarget,
          points: 0,
          achieved: false,
          medalAsset: 'assets/icon/medal_custom.png',
        ),
      );
    }
    return milestones;
  }
}

class _HabitProgress {
  final Habit habit;
  final double percent;
  final int completedDays;

  _HabitProgress({
    required this.habit,
    required this.percent,
    required this.completedDays,
  });
}
